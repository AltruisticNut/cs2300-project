from flask import Flask, redirect, render_template, json, jsonify, request
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

# Get advancement data
@app.route('/')
def main():
    conn = mysql.connect()
    cursor = conn.cursor()

    # Retrieve advancement data
    cursor.execute("SELECT advancement_id, advancement_name, tab_id, description, completion_percentage, is_completed, is_available, parent_advancement_id, rewards, resource_path FROM Advancements ORDER BY advancement_id ASC")  # Example table
    advancements = cursor.fetchall()

    # Retrieve world data
    cursor.execute("SELECT world_id, world_name, completion_percentage, created_at FROM Worlds ORDER BY world_id ASC")  # Example table
    worlds = cursor.fetchall()

    # Retrieve tab data
    cursor.execute("SELECT tab_id, world_id, tab_name, completion_percentage FROM Tabs ORDER BY tab_id ASC")  # Example table
    tabs = cursor.fetchall()

    # Calculate Completion
    world_completion = 0    # World
    mc_completion = 0       # Minecraft
    tn_completion = 0       # The Nether
    te_completion = 0       # The End
    ad_completion = 0       # Adventure
    hu_completion = 0       # Husbandry
    for advancement in advancements:
        if advancement[5]:
            world_completion += 1
            if advancement[2] == 1:
                mc_completion += 1
            elif advancement[2] == 2:
                tn_completion += 1
            elif advancement[2] == 3:
                te_completion += 1
            elif advancement[2] == 4:
                ad_completion += 1
            elif advancement[2] == 5:
                hu_completion += 1
    # World
    world_completion /= 110
    world_completion *= 100
    # Minecraft
    mc_completion /= 16
    mc_completion *= 100
    # The Nether
    tn_completion /= 24
    tn_completion *= 100
    # The End
    te_completion /= 9
    te_completion *= 100
    # Adventure
    ad_completion /= 35
    ad_completion *= 100
    # Husbandry
    hu_completion /= 26
    hu_completion *= 100
    # Update all of the values
    cursor.execute("UPDATE Worlds SET completion_percentage = %s", (world_completion))
    cursor.execute("UPDATE Tabs SET completion_percentage = %s WHERE tab_id = 1", (mc_completion))
    cursor.execute("UPDATE Tabs SET completion_percentage = %s WHERE tab_id = 2", (tn_completion))
    cursor.execute("UPDATE Tabs SET completion_percentage = %s WHERE tab_id = 3", (te_completion))
    cursor.execute("UPDATE Tabs SET completion_percentage = %s WHERE tab_id = 4", (ad_completion))
    cursor.execute("UPDATE Tabs SET completion_percentage = %s WHERE tab_id = 5", (hu_completion))
    conn.commit()

    # Check advancement availability
    for advancement in advancements:
        if advancement[7]:
            cursor.execute("SELECT advancement_id, is_completed FROM Advancements WHERE advancement_id = %s", (advancement[7]))
            advancement_check = cursor.fetchone()
            if not advancement_check[1] and advancement_check[0]:
                cursor.execute(
                    "UPDATE Advancements SET is_available = FALSE WHERE advancement_id = %s",
                    (advancement[0])
                )
                conn.commit()
            else:
                cursor.execute("UPDATE Advancements SET is_available = TRUE WHERE advancement_id = %s", (advancement[0]))
                conn.commit()
        else:
            cursor.execute("UPDATE Advancements SET is_available = TRUE WHERE advancement_id = %s", (advancement[0]))
            conn.commit()
    

    # Get parent advancement data
    query = """
        SELECT 
            a.advancement_id,
            a.parent_advancement_id,
            b.advancement_id,
            b.parent_advancement_id,
            b.advancement_name
        FROM Advancements a
        LEFT JOIN Advancements b ON b.advancement_id = a.parent_advancement_id
    """
    cursor.execute(query)
    parent_advancements = cursor.fetchall()

    cursor.close()
    return render_template('index.html', advancements=advancements, worlds=worlds, tabs=tabs, parent_advancements=parent_advancements)

# Toggle achievement completion
@app.route('/toggle/<int:adv_id>', methods=['POST'])
def toggle(adv_id):
    conn = mysql.connect()
    cursor = conn.cursor()
    cursor.execute("UPDATE Advancements SET is_completed = NOT is_completed WHERE advancement_id = %s", (adv_id))
    conn.commit()
    cursor.close()
    return redirect('/')
    
# Search functionality with tab filtering may or may not work lines 46-80
@app.route('/', methods=['GET', 'POST'])
def search():
    conn = mysql.connect()
    cursor = conn.cursor()
    
    search_query = ''
    
    if request.method == 'POST':
        search_query = request.form.get('search', '').strip()
        # Search advancements by name, description, or rewards for the current tab
        query = """
            SELECT 
                a.advancement_id, 
                a.advancement_name, 
                a.tab_id, 
                a.description,
                a.completion_percentage,
                a.is_completed,
                a.is_available,
                a.parent_advancement_id,
                a.rewards,
                a.resource_path
            FROM Advancements a
            WHERE a.advancement_name LIKE %s 
                  OR a.description LIKE %s 
                  OR a.rewards LIKE %s
            ORDER BY a.advancement_id ASC
        """
        like_pattern = f'%{search_query}%'
        cursor.execute(query, (like_pattern, like_pattern, like_pattern))
    else:
        # Original query for all advancements (no tab filter for GET to maintain original behavior)
        cursor.execute("SELECT advancement_id, advancement_name, tab_id, description, completion_percentage, is_completed, is_available, parent_advancement_id, rewards, resource_path FROM Advancements ORDER BY advancement_id ASC")  # Example table
    
    advancements = cursor.fetchall()

    # Retrieve world data
    cursor.execute("SELECT world_id, world_name, completion_percentage, created_at FROM Worlds ORDER BY world_id ASC")  # Example table
    worlds = cursor.fetchall()

    # Retrieve tab data
    cursor.execute("SELECT tab_id, world_id, tab_name, completion_percentage FROM Tabs ORDER BY tab_id ASC")  # Example table
    tabs = cursor.fetchall()

    # Calculate Completion
    world_completion = 0    # World
    mc_completion = 0       # Minecraft
    tn_completion = 0       # The Nether
    te_completion = 0       # The End
    ad_completion = 0       # Adventure
    hu_completion = 0       # Husbandry
    for advancement in advancements:
        if advancement[5]:
            world_completion += 1
            if advancement[2] == 1:
                mc_completion += 1
            elif advancement[2] == 2:
                tn_completion += 1
            elif advancement[2] == 3:
                te_completion += 1
            elif advancement[2] == 4:
                ad_completion += 1
            elif advancement[2] == 5:
                hu_completion += 1
    # World
    world_completion /= 110
    world_completion *= 100
    # Minecraft
    mc_completion /= 16
    mc_completion *= 100
    # The Nether
    tn_completion /= 24
    tn_completion *= 100
    # The End
    te_completion /= 9
    te_completion *= 100
    # Adventure
    ad_completion /= 35
    ad_completion *= 100
    # Husbandry
    hu_completion /= 26
    hu_completion *= 100
    # Update all of the values
    cursor.execute("UPDATE Worlds SET completion_percentage = %s", (world_completion))
    cursor.execute("UPDATE Tabs SET completion_percentage = %s WHERE tab_id = 1", (mc_completion))
    cursor.execute("UPDATE Tabs SET completion_percentage = %s WHERE tab_id = 2", (tn_completion))
    cursor.execute("UPDATE Tabs SET completion_percentage = %s WHERE tab_id = 3", (te_completion))
    cursor.execute("UPDATE Tabs SET completion_percentage = %s WHERE tab_id = 4", (ad_completion))
    cursor.execute("UPDATE Tabs SET completion_percentage = %s WHERE tab_id = 5", (hu_completion))
    conn.commit()

    # Check advancement availability
    for advancement in advancements:
        if advancement[7]:
            cursor.execute("SELECT advancement_id, is_completed FROM Advancements WHERE advancement_id = %s", (advancement[7]))
            advancement_check = cursor.fetchone()
            if not advancement_check[1] and advancement_check[0]:
                cursor.execute(
                    "UPDATE Advancements SET is_available = FALSE WHERE advancement_id = %s",
                    (advancement[0])
                )
                conn.commit()
            else:
                cursor.execute("UPDATE Advancements SET is_available = TRUE WHERE advancement_id = %s", (advancement[0]))
                conn.commit()
        else:
            cursor.execute("UPDATE Advancements SET is_available = TRUE WHERE advancement_id = %s", (advancement[0]))
            conn.commit()
    

    # Get parent advancement data
    query = """
        SELECT 
            a.advancement_id,
            a.parent_advancement_id,
            b.advancement_id,
            b.parent_advancement_id,
            b.advancement_name
        FROM Advancements a
        LEFT JOIN Advancements b ON b.advancement_id = a.parent_advancement_id
    """
    cursor.execute(query)
    parent_advancements = cursor.fetchall()

    cursor.close()
    conn.close()
    return render_template('index.html', advancements=advancements, worlds=worlds, tabs=tabs, parent_advancements=parent_advancements, search_query=search_query)

# Add a world to the database
@app.route('/addWorld', methods=['GET', 'POST'])
def addWorld():
    conn = mysql.connect()
    cursor = conn.cursor()

    textbox = ''

    if request.method == 'POST':
        textbox = request.form['WorldBox']

    cursor.execute("INSERT INTO Worlds (world_name) VALUES (%s)", (textbox))

    conn.commit()
    cursor.close()
    conn.close()

    return redirect('/')

# Delete a world from the database
@app.route('/deleteWorld', methods=['GET', 'POST'])
def deleteWorld():
    conn = mysql.connect()
    cursor = conn.cursor()

    dropdown = request.form['WorldDropdown']

    cursor.execute("DELETE FROM Worlds WHERE world_id = %s", (dropdown))

    conn.commit()
    cursor.close()
    conn.close()

    return redirect('/')

# Run the app
if __name__ == "__main__":
    app.run()
