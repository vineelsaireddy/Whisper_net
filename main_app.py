import pymysql
import sys
from getpass import getpass

# --- CONFIGURATION ---
DB_HOST = 'localhost'
DB_NAME = 'whispernet_db'

def get_db_connection(db_user, db_pass):
    """Establishes a connection to the MySQL database."""
    try:
        connection = pymysql.connect(
            host=DB_HOST,
            user=db_user,
            password=db_pass,
            database=DB_NAME,
            cursorclass=pymysql.cursors.DictCursor,
            autocommit=True 
        )
        print(">> Database connection successful.")
        return connection
    except pymysql.Error as e:
        print(f"Error connecting to MySQL Database: {e}", file=sys.stderr)
        return None

# --- READ OPERATIONS ---

def query_agents_by_handler(connection):
    """1. List all agents managed by a specific handler (Officer)."""
    print("\n--- QUERY: Agents by Handler ---")
    handler_name = input("Enter Handler Name (e.g., Varys the Spider): ").strip()
    
    sql = """
    SELECT a.AgentID, a.CurrentStatus, a.ExposureRiskLevel, io.Name as Handler
    FROM Agent a
    JOIN IntelligenceOfficer io ON a.HandlerID = io.OfficerID
    WHERE io.Name = %s
    """
    
    with connection.cursor() as cursor:
        cursor.execute(sql, (handler_name,))
        results = cursor.fetchall()
        if not results:
            print("No agents found for this handler.")
        else:
            for row in results:
                print(f"Agent ID: {row['AgentID']}, Status: {row['CurrentStatus']}, Risk: {row['ExposureRiskLevel']}")


def query_mission_details(connection):
    """2. Show details of a mission and the House it targets."""
    print("\n--- QUERY: Mission Details ---")
    status_input = input("Enter Mission Status to filter (e.g., Ongoing, Completed): ").strip()
    
    sql = """
    SELECT m.MissionID, m.MissionObjective, h.HouseName, m.RiskLevel
    FROM Mission m
    JOIN House h ON m.TargetHouse = h.HouseID
    WHERE m.Status = %s
    """
    
    with connection.cursor() as cursor:
        cursor.execute(sql, (status_input,))
        results = cursor.fetchall()
        if not results:
            print(f"No missions found with status '{status_input}'.")
        else:
            for row in results:
                print(f"ID: {row['MissionID']} | Obj: {row['MissionObjective']} | Target: {row['HouseName']}")

def query_high_value_intel(connection):
    """3. List Intelligence reports with credibility above a certain score."""
    print("\n--- QUERY: High Value Intel ---")
    min_score = input("Enter minimum credibility score (1-10): ").strip()
    
    sql = """
    SELECT i.IntelligenceID, i.IntelligenceType, i.CredibilityRating, l.LocationName
    FROM Intelligence i
    JOIN Location l ON i.LocationGathered = l.LocationID
    WHERE i.CredibilityRating >= %s
    ORDER BY i.CredibilityRating DESC
    """
    
    with connection.cursor() as cursor:
        cursor.execute(sql, (min_score,))
        results = cursor.fetchall()
        for row in results:
            print(f"Intel #{row['IntelligenceID']} ({row['IntelligenceType']}) - Credibility: {row['CredibilityRating']}")

def query_embedded_agents(connection):
    """4. List Embedded Agents and their cover identities."""
    print("\n--- QUERY: Embedded Agents ---")
    
    sql = """
    SELECT ea.CoverIdentity, ea.CoverOccupation, h.HouseName, a.CurrentStatus
    FROM EmbeddedAgent ea
    JOIN Agent a ON ea.AgentID = a.AgentID
    JOIN House h ON ea.HouseInfiltrated = h.HouseID
    """
    
    with connection.cursor() as cursor:
        cursor.execute(sql)
        results = cursor.fetchall()
        for row in results:
            print(f"Cover: {row['CoverIdentity']} ({row['CoverOccupation']}) inside {row['HouseName']}")

def query_house_strength(connection):
    """5. Aggregate: Show average military strength of Houses."""
    print("\n--- QUERY: House Stats ---")
    
    sql = """
    SELECT HouseName, MilitaryStrength, WealthLevel
    FROM House
    ORDER BY MilitaryStrength DESC
    """
    
    with connection.cursor() as cursor:
        cursor.execute(sql)
        results = cursor.fetchall()
        print(f"{'House Name':<20} | {'Strength':<10} | {'Wealth':<10}")
        print("-" * 45)
        for row in results:
            print(f"{row['HouseName']:<20} | {row['MilitaryStrength']:<10} | {row['WealthLevel']:<10}")

# --- WRITE OPERATIONS ---

def insert_new_intel(connection):
    """6. INSERT: Add a new piece of Intelligence."""
    print("\n--- INSERT: New Intelligence ---")
    content = input("Enter Intel Content: ")
    intel_type = input("Enter Type (e.g., Rumor, Military): ")
    cred = input("Enter Credibility (1-10): ")
    loc_id = input("Enter Location ID (e.g., 1): ")
    
    sql = """
    INSERT INTO Intelligence (IntelligenceType, Content, DateGathered, LocationGathered, CredibilityRating, VerificationStatus, StrategicValue, SensitivityLevel)
    VALUES (%s, %s, NOW(), %s, %s, 'Unverified', 5, 'Classified')
    """
    
    try:
        with connection.cursor() as cursor:
            cursor.execute(sql, (intel_type, content, loc_id, cred))
        print("Success! New Intelligence inserted.")
    except pymysql.Error as e:
        print(f"Error: {e}")

def update_agent_status(connection):
    """7. UPDATE: Change an Agent's status."""
    print("\n--- UPDATE: Agent Status ---")
    agent_id = input("Enter Agent ID to update: ")
    new_status = input("Enter new status (e.g., Burned, KIA, Deep Cover): ")
    
    sql = "UPDATE Agent SET CurrentStatus = %s WHERE AgentID = %s"
    
    try:
        with connection.cursor() as cursor:
            cursor.execute(sql, (new_status, agent_id))
        print(f"Success! Agent {agent_id} status updated to {new_status}.")
    except pymysql.Error as e:
        print(f"Error: {e}")

def delete_mission(connection):
    """8. DELETE: Remove a mission."""
    print("\n--- DELETE: Remove Mission ---")
    mission_id = input("Enter Mission ID to delete: ")
    confirm = input("Are you sure? (yes/no): ")
    
    if confirm.lower() == 'yes':
        sql = "DELETE FROM Mission WHERE MissionID = %s"
        try:
            with connection.cursor() as cursor:
                cursor.execute(sql, (mission_id,))
            print(f"Success! Mission {mission_id} deleted.")
        except pymysql.Error as e:
            print(f"Error: {e}")
    else:
        print("Operation cancelled.")

# --- MAIN MENU ---

def main_cli(connection):
    while True:
        print("\n========== WHISPERNET TERMINAL ==========")
        print("1: Find Agents by Handler (READ)")
        print("2: Find Missions by Status (READ)")
        print("3: High Credibility Intel (READ)")
        print("4: List Embedded Agents (READ)")
        print("5: House Military Strength Stats (READ)")
        print("6: Insert New Intelligence (WRITE - INSERT)")
        print("7: Update Agent Status (WRITE - UPDATE)")
        print("8: Delete Mission (WRITE - DELETE)")
        print("q: Quit")
        print("=========================================")
        
        choice = input("Enter command: ").strip().lower()
        
        if choice == '1': query_agents_by_handler(connection)
        elif choice == '2': query_mission_details(connection)
        elif choice == '3': query_high_value_intel(connection)
        elif choice == '4': query_embedded_agents(connection)
        elif choice == '5': query_house_strength(connection)
        elif choice == '6': insert_new_intel(connection)
        elif choice == '7': update_agent_status(connection)
        elif choice == '8': delete_mission(connection)
        elif choice == 'q': 
            print("Terminating link...")
            break
        else:
            print("Invalid command.")

if __name__ == "__main__":
    print("Initialize WhisperNet...")
    user = input("MySQL Username: ").strip()
    pwd = getpass("MySQL Password: ")
    
    conn = get_db_connection(user, pwd)
    if conn:
        main_cli(conn)
        conn.close()