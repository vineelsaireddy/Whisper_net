-- populate.sql
-- WhisperNet Data Population

USE whispernet_db;

-- 1. Insert Officers (Fixed "Rank" keyword issue)
INSERT INTO IntelligenceOfficer (Name, `Rank`) VALUES 
('Varys the Spider', 'Master of Whisperers'),
('Qyburn', 'Hand of the Queen'),
('Larys Strong', 'Lord Confessor');

-- 2. Insert Houses
INSERT INTO House (HouseName, Sigil, Words, SeatLocation, MilitaryStrength, WealthLevel) VALUES 
('House Lannister', 'Lion', 'Hear Me Roar', 'Casterly Rock', 8000, 100),
('House Stark', 'Direwolf', 'Winter is Coming', 'Winterfell', 5000, 40),
('House Targaryen', 'Dragon', 'Fire and Blood', 'Dragonstone', 3000, 20);

-- 3. Insert Locations
INSERT INTO Location (LocationName, LocationType, Region, ControllingHouse) VALUES 
('Kings Landing', 'Capital City', 'Crownlands', 1),
('Winterfell', 'Castle', 'The North', 2),
('Dragonstone', 'Fortress', 'Blackwater Bay', 3);

-- 4. Insert Persons
INSERT INTO Person (FullName, HouseID, CurrentLocationID, BirthYear, Status, StrategicImportance, LastVerifiedDate) VALUES 
('Cersei Lannister', 1, 1, 266, 'Alive', 10, '2025-10-01 10:00:00'),
('Jon Snow', 2, 2, 283, 'Alive', 9, '2025-10-05 12:00:00'),
('Daenerys Targaryen', 3, 3, 284, 'Alive', 10, '2025-10-06 14:00:00');

-- 5. Insert Agents
-- Agent 1: Embedded
INSERT INTO Agent (RecruitmentDate, CurrentStatus, CredibilityScore, ExposureRiskLevel, LastContactDate, HandlerID) VALUES 
('2020-01-01', 'Active', 95, 'High', '2025-11-10 23:00:00', 1);

-- Agent 2: Little Bird
INSERT INTO Agent (RecruitmentDate, CurrentStatus, CredibilityScore, ExposureRiskLevel, LastContactDate, HandlerID) VALUES 
('2024-05-15', 'Active', 80, 'Low', '2025-11-12 09:00:00', 1);

-- 6. Insert Sub-Types for Agents
INSERT INTO EmbeddedAgent (AgentID, PersonID, CoverIdentity, CoverOccupation, HouseInfiltrated, YearsDeepCover, ProximityToLeadership) VALUES 
(1, NULL, 'Shae', 'Handmaiden', 1, 3, 9);

INSERT INTO LittleBird (AgentID, CodeName, Age, OperatingCity, Specialization, MobilityLevel) VALUES 
(2, 'Sparrow 1', 10, 'Kings Landing', 'Eavesdropping', 'High');

-- 7. Insert Intelligence
INSERT INTO Intelligence (IntelligenceType, Content, DateGathered, LocationGathered, CredibilityRating, VerificationStatus, StrategicValue, SensitivityLevel) VALUES 
('Military Movement', 'Lannister army gathering at Kings Landing', '2025-11-01', 1, 9, 'Verified', 8, 'Top Secret'),
('Political Gossip', 'Cersei is plotting against the Tyrells', '2025-11-02', 1, 7, 'Unverified', 5, 'Confidential');

-- 8. Insert Missions
INSERT INTO Mission (MissionObjective, TargetHouse, StartDate, ExpectedCompletionDate, Status, RiskLevel) VALUES 
('Infiltrate Red Keep', 1, '2025-11-01', '2025-12-01', 'Ongoing', 'Extreme'),
('Scout the Wall', 2, '2025-10-01', '2025-10-30', 'Completed', 'Moderate');

-- 9. Insert Agent_Mission (Linking Agents to Missions)
INSERT INTO Agent_Mission (AgentID, MissionID, AssignmentDate, Role, SuccessContribution) VALUES 
(1, 1, '2025-11-01', 'Infiltrator', 0);

-- 10. Insert Secret
INSERT INTO Secret (SecretDescription, SecretCategory, DateDiscovered, VerifiedStatus, PotentialLeverage, RevealedStatus) VALUES 
('Wildfire caches under the city', 'Military', '2025-09-01', 1, 10, 0);

-- 11. Insert Person_Secret
INSERT INTO Person_Secret (PersonID, SecretID, InvolvementType) VALUES 
(1, 1, 'Planner');