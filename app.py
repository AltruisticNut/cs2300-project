from flask import Flask, redirect, render_template, json, request
from flaskext.mysql import MySQL
from werkzeug.security import generate_password_hash, check_password_hash

app = Flask(__name__)

mysql = MySQL()
# MySQL configurations 
app.config['MYSQL_DATABASE_USER'] = 'root'
app.config['MYSQL_DATABASE_PASSWORD'] = 'advancement'
app.config['MYSQL_DATABASE_DB'] = 'sys'
app.config['MYSQL_DATABASE_HOST'] = 'localhost'
mysql.init_app(app)

@app.route('/')
def main():
    conn = mysql.connect()
    cursor = conn.cursor()
    cursor.execute("SELECT advancement_id, advancement_name, tab_id, description, is_completed FROM Advancements ORDER BY advancement_id ASC")  # Example table
    users = cursor.fetchall()
    cursor.close()
    return render_template('index.html', users=users)

@app.route('/update', methods=['POST'])
def update():
   # Get selected checkboxes from the form (which are sent as a list)
    selected_ids = request.form.getlist('completed_box')
    print(len(selected_ids))
    
    # Connect to the database
    conn = mysql.connect()
    cursor = conn.cursor()

    id_num = 0
    for record_id in selected_ids:
        id_num += 1
        cursor.execute("UPDATE Advancements SET is_completed = %s WHERE advancement_id = %s", (False, record_id))
        print(record_id)
        print(id_num)
    

    # Commit the changes and close the connection
    conn.commit()
    cursor.close()
    conn.close()

    # Redirect back to the index page
    return redirect('/')

# Search functionality with tab filtering may or may not work lines 46-80
@app.route('/', methods=['GET', 'POST'])
def search():
    conn = mysql.connect()
    cursor = conn.cursor()
    
    search_query = ''
    tab_id = '1'  # Default to Minecraft tab (tab_id=1)
    
    if request.method == 'POST':
        search_query = request.form.get('search', '').strip()
        tab_id = request.form.get('tab_id', '1')  # Get tab_id from form, default to 1
        # Search advancements by name, description, or rewards for the current tab
        query = """
            SELECT 
                a.advancement_id, 
                a.advancement_name, 
                a.tab_id, 
                a.description
            FROM Advancements a
            WHERE a.tab_id = %s
              AND (a.advancement_name LIKE %s 
                   OR a.description LIKE %s 
                   OR a.rewards LIKE %s)
            ORDER BY a.advancement_id ASC
        """
        like_pattern = f'%{search_query}%'
        cursor.execute(query, (tab_id, like_pattern, like_pattern, like_pattern))
    else:
        # Original query for all advancements (no tab filter for GET to maintain original behavior)
        cursor.execute("SELECT advancement_id, advancement_name, tab_id, description FROM Advancements ORDER BY advancement_id ASC")
    
    users = cursor.fetchall()
    cursor.close()
    conn.close()
    return render_template('index.html', users=users, search_query=search_query, tab_id=tab_id)

@app.route('/signup')
def signup():
    return render_template('signup.html')

@app.route('/api/signup', methods=['POST'])
def signUp():
    try:
        _name = request.form['inputName']
        _email = request.form['inputEmail']
        _password = request.form['inputPassword']

        # validate the received values
        if _name and _email and _password:

            # All Good, let's call MySQL

            conn = mysql.connect()
            cursor = conn.cursor()
            # this would always make it too long so i got mad and just didn't hash it :C
            _hashed_password = generate_password_hash(_password) 
            cursor.callproc('sp_createUser', (_name, _email, _password))
            data = cursor.fetchall()

            if len(data) == 0:
                conn.commit()
                return json.dumps({'message': 'User created successfully !'})
            else:
                return json.dumps({'error': str(data[0])})
        else:
            return json.dumps({'html': '<span>Enter the required fields</span>'})

    except Exception as e:
        return json.dumps({'error': str(e)})
    finally:
        cursor.close()
        conn.close()

if __name__ == "__main__":
    app.run()
