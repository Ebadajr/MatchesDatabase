CREATE DATABASE NEW;
go;
CREATE PROCEDURE createAllTables
AS BEGIN
CREATE TABLE SystemUser(
username varchar(20) PRIMARY KEY,
password varchar(20)
);
CREATE TABLE SAM(
name varchar(20),
id int PRIMARY KEY IDENTITY,
username varchar(20),
FOREIGN KEY (username) references SystemUser(username)
);
CREATE TABLE System_Admin(
name varchar(20),
id int PRIMARY KEY IDENTITY,
username varchar(20),
FOREIGN KEY (username) references SystemUser(username)
);
CREATE TABLE Club(
name varchar(20),
id int PRIMARY KEY IDENTITY,
location varchar(20)
);
CREATE TABLE Stadium(
id int PRIMARY KEY IDENTITY,
sname varchar(20),
capacity int,
location varchar(20),
status bit
);
CREATE TABLE Stadium_Manager(
name varchar(20),
id int PRIMARY KEY IDENTITY,
username varchar(20),
sid int,
FOREIGN KEY (username) references SystemUser(username),
FOREIGN KEY (sid) REFERENCES Stadium(id)
);
CREATE TABLE Club_representative(
cname varchar(20),
id int PRIMARY KEY IDENTITY,
username varchar(20),
cid int,
FOREIGN KEY (username) references SystemUser(username),
FOREIGN KEY (cid) REFERENCES Club(id)
);
CREATE TABLE Fan(
national_id int PRIMARY KEY,
Birth Date,
phoneNo int,
name varchar(20),
adress varchar(20),
status bit,
username varchar(20),
FOREIGN KEY (username) references SystemUser(username)


);
CREATE TABLE Match(
id int PRIMARY KEY IDENTITY,
start_time datetime,
end_time datetime,
sid int,
cidH int,
cidG int,
FOREIGN KEY (sid) REFERENCES Stadium(id),
FOREIGN KEY (cidH) REFERENCES Club(id),
FOREIGN KEY (cidG) REFERENCES Club(id)
);
CREATE TABLE Host_request(
id int PRIMARY KEY IDENTITY,
status varchar(20) DEFAULT 'UNHANDLED',
match_id int,
sid int,
cid int,
FOREIGN KEY (sid) REFERENCES Stadium_Manager(id),
FOREIGN KEY (cid) REFERENCES Club_Representative(id),
FOREIGN KEY (match_id) REFERENCES Match(id)
);
CREATE TABLE Ticket(
id int PRIMARY KEY IDENTITY,
status bit,
MID int,
FOREIGN KEY (MID) REFERENCES Match(id)
);

CREATE TABLE TICKET_BUYING_TRANSACTIONS(
fan_national_id int ,
ticket_id int,
FOREIGN KEY (fan_national_id) REFERENCES FAN(national_id),
FOREIGN KEY (ticket_id) REFERENCES Ticket(id));



END;
GO;

go;

go;
CREATE PROCEDURE dropAllTables
AS begin
EXEC sys.sp_msforeachtable 'ALTER TABLE ? NOCHECK CONSTRAINT ALL'
DROP TABLE SAM;
DROP TABLE Match;
DROP TABLE Stadium;
DROP TABLE Stadium_Manager;
DROP TABLE Club;
DROP TABLE Club_representative;
DROP TABLE System_Admin;
DROP TABLE Fan;
DROP TABLE Ticket;
DROP TABLE Host_request;
DROP TABLE SystemUser;
DROP TABLE TICKET_BUYING_TRANSACTIONS;

end;

go;

CREATE PROCEDURE clearAllTables
AS begin

DELETE FROM SystemUser;
DELETE FROM SAM;
DELETE FROM Match;
DELETE FROM Stadium;
DELETE FROM Stadium_Manager;
DELETE FROM Club;
DELETE FROM Club_representative;
DELETE FROM System_Admin;
DELETE FROM Fan;
DELETE FROM Ticket;
DELETE FROM Host_request;
end;
go;

CREATE PROCEDURE dropAllProceduresFunctionsViews
AS BEGIN
DROP PROCEDURE IF EXISTS createAllTables
DROP PROCEDURE IF EXISTS dropAllTables
DROP PROCEDURE IF EXISTS clearAllTables
DROP PROCEDURE IF EXISTS addAssociationManager
DROP PROCEDURE IF EXISTS addNewMatch
DROP PROCEDURE IF EXISTS deletematch
DROP PROCEDURE IF EXISTS deleteClub
DROP PROCEDURE IF EXISTS deleteMatchesOnStadium
DROP PROCEDURE IF EXISTS addClub
DROP PROCEDURE IF EXISTS addTICKET
DROP PROCEDURE IF EXISTS deleteStadium
DROP PROCEDURE IF EXISTS addStadium
DROP PROCEDURE IF EXISTS blockFan
DROP PROCEDURE IF EXISTS unblockFan
DROP PROCEDURE IF EXISTS addRepresentative
DROP PROCEDURE IF EXISTS addHostRequest
DROP PROCEDURE IF EXISTS addStadiumManager
DROP PROCEDURE IF EXISTS acceptRequest
DROP PROCEDURE IF EXISTS rejectRequest
DROP PROCEDURE IF EXISTS addFan
DROP PROCEDURE IF EXISTS purchaseTicket
DROP PROCEDURE IF EXISTS updateMatchHost
DROP VIEW IF EXISTS allAssocManagers
DROP VIEW IF EXISTS allClubRepresentatives
DROP VIEW IF EXISTS  allStadiumManagers
DROP VIEW IF EXISTS allFans
DROP VIEW IF EXISTS allMatches
DROP VIEW IF EXISTS allTickets
DROP VIEW IF EXISTS allClubs
DROP VIEW IF EXISTS allStadiums
DROP VIEW IF EXISTS allRequests
DROP VIEW IF EXISTS clubsWithNoMatches
DROP VIEW IF EXISTS matchesPerTeam
DROP VIEW IF EXISTS clubsNeverMatched
DROP FUNCTION IF EXISTS viewAvailableStadiumsOn
DROP FUNCTION IF EXISTS allUnassignedMatches
DROP FUNCTION IF EXISTS allPendingRequests
DROP FUNCTION IF EXISTS upcomingMatchesOfClub
DROP FUNCTION IF EXISTS availableMatchesToAttend
DROP FUNCTION IF EXISTS clubsNeverPlayed
DROP FUNCTION IF EXISTS matchWithHighestAttendance
DROP FUNCTION IF EXISTS matchesRankedByAttendance
DROP FUNCTION IF EXISTS requestsFromClub

end;






go;
CREATE VIEW  allAssocManagers
AS
select s.username,S.name,ss.password
FROM SAM s INNER JOIN SystemUser ss on s.username=ss.username

go;

CREATE VIEW allClubRepresentatives
AS
select cr.username,SS.password, cr.cname
FROM Club_representative cr inner join Club c on (cr.cid=c.id) 
INNER JOIN SystemUser ss on cr.username=ss.username
go;

CREATE VIEW allStadiumManagers
AS
select st.username, su.password, st.name AS Manager , S.sname AS Stadium
FROM Stadium_Manager st inner join Stadium s on (st.id=s.id) inner join SystemUser su on(su.username=st.username)
inner join SystemUser ss on st.username=ss.username



go;

CREATE VIEW allFans
AS
select f.username,ss.password, name, national_id, birth, status
from Fan f inner join SystemUser ss on f.username=ss.username


go;

CREATE VIEW allMatches
AS
Select c.name AS FirstClub, c1.name AS Secondclub, M.start_time
FROM Match m inner join Club c ON (m.cidH=c.id) inner join Club c1 ON (m.cidG=c1.id) 
go;

CREATE VIEW allTickets
AS
select c.name AS HOST, c1.name AS GUEST, s.sname AS stadium, m.start_time
FROM Ticket t inner join Match m on(t.MID=m.id) inner join Club c ON (m.cidH=c.id) inner join Club c1 ON (m.cidG=c1.id) inner join Stadium s on(M.sid=s.id)

go;

CREATE VIEW allClubs
AS
select name,location
from Club 

go;
CREATE VIEW allStadiums
AS
select  sname ,location, capacity, status
from Stadium
go;

CREATE VIEW allRequests
AS
SELECT c.username as repUSER, s.username as sUSER, h.status
FROM Host_request h inner join Club_representative c on(h.cid=c.cid)inner join Stadium_Manager s on(s.id=h.sid)


go;

CREATE PROCEDURE  addAssociationManager
@name varchar(20),
@username varchar(20),
@password varchar(20)
AS begin
INSERT INTO SystemUser VALUES(@username,@password)
INSERT INTO SAM VALUES(@name,@username)
end;
go;

CREATE PROCEDURE addNewMatch
@hostClub varchar(20),
@guestClub varchar(20),
@start datetime,
@end datetime
AS BEGIN
DECLARE @HostID int
DECLARE @GuestID int

SELECT @HostID=c.id
from club c
where c.name=@hostClub

SELECT @GuestID=c.id
from Club c
where c.name=@guestClub

INSERT INTO MATCH VALUES(@start,@end,null,@HostID,@GuestID)
end;



go;
CREATE VIEW clubsWithNoMatches
AS
select c.name
from Club c
Where NOT EXISTS
(select m1.cidG, m1.cidH 
from Match m1 
where m1.cidG=c.id OR m1.cidH=c.id);
GO;


CREATE PROC deletematch
@hostname varchar(20),
@guestname varchar(20)
AS
DECLARE @hostid int
DECLARE @GUESTID INT

SELECT @hostid=id
FROM CLUB
WHERE @hostname=name

SELECT @GUESTID=id
FROM CLUB
WHERE @guestname=name

DELETE FROM MATCH
WHERE @hostid=cidH and @GUESTID=cidG;

go;

CREATE PROC deleteMatchesOnStadium
@stadiumname varchar(20)
AS
DECLARE  @SID INT
SELECT @SID=id
FROM Stadium
WHERE @stadiumname=sname 

DELETE FROM MATCH 
WHERE  @sid=sid and start_time > CURRENT_TIMESTAMP
 GO;

CREATE PROCEDURE addClub
@name varchar(20),
@location varchar(20)
AS begin
INSERT INTO Club VALUES(@name,@location)
end;
go;

CREATE PROC addTICKET
@hostname varchar(20),
@guestname varchar(20),
@starttime datetime
AS
DECLARE @hid int
Declare @gid int
DECLARE @mid int

SELECT @gid=id
from Club
where name=@guestname

SELECT @hid=id
from Club
where name=@hostname

SELECT @mid=id
from Match m
where m.cidG=@gid and m.cidH=@hid and m.start_time=@starttime

INSERT INTO TICKET VALUES(1,@mid)



GO;


CREATE PROCEDURE addStadium
@name varchar(20),
@location varchar(20),
@c int
AS begin
INSERT INTO Stadium VALUES(@name,@c,@location,1)
end;
go;

CREATE PROCEDURE deleteClub
@name varchar(20)
AS begin 
DELETE FROM Club where name=@name
end;
go;
CREATE PROCEDURE deleteStadium
@name varchar(20)
AS begin 
DELETE FROM Stadium where sname=@name
end;
go;
CREATE PROCEDURE blockFan
@nID int
AS begin
UPDATE Fan SET status=0 WHERE Fan.national_id=@nID
end;


go;
CREATE PROCEDURE unblockFan
@nID int
AS begin
UPDATE Fan SET status=1 WHERE Fan.national_id=@nID
end;
go;

CREATE PROCEDURE addRepresentative
@name varchar(20),
@clubname varchar(20),
@username varchar(20),
@password varchar(20)
AS
Declare @x int
Select @x=id  from Club
Where name=@clubname

INSERT INTO SystemUser VALUES (@username, @password)
INSERT INTO Club_representative VALUES (@name,@username,@x)
go;

CREATE PROCEDURE addFan
@name varchar(20),
@username varchar(20),
@password varchar(20),
@nationalid varchar(20),
@birthdate datetime,
@address varchar(20),
@phoneno int
AS
INSERT INTO SystemUser VALUES(@username,@password)
INSERT INTO FAN VALUES (@nationalid,@birthdate,@phoneno,@name,@address,1,@username);
go;

CREATE PROC addStadiumManager
@name varchar(20),
@stadiumname varchar(20),
@username varchar(20),
@password varchar(20)
AS
declare @stadiumid int

SELECT @stadiumid=id
FROM Stadium
WHERE @stadiumname=sname
INSERT INTO Stadium_Manager VALUES (@name,@username,@stadiumid)
INSERT INTO SystemUser VALUES (@username, @password)

GO;


CREATE FUNCTION[upcomingMatchesOfClub]
(@clubname varchar(20))
returns @upcomingmatches table(
clubname varchar(20),
competingclubname varchar(20),
starttime datetime,
stadiumname varchar(20) )
AS
BEGIN

DECLARE @clubID int

SELECT @clubID=id
from Club c
where c.name=@clubname

INSERT INTO @upcomingmatches  SELECT  c.name , c1.name ,m.start_time, s.sname
FROM Club c INNER JOIN MATCH m on (c.id=m.cidH) inner join club c1 on(m.cidG=c1.id) inner join Stadium s on(m.sid=s.id)
WHERE @clubID=c.id and m.start_time >  CURRENT_TIMESTAMP


return
END;
go;
CREATE FUNCTION[availableMatchesToAttend]
(@date datetime)
returns @availableMatches table(
clubname varchar(20),
competingclubname varchar(20),
starttime datetime,
stadiumname varchar(20) )
AS
BEGIN
DECLARE @matchid table(ids int)

INSERT INTO @matchid SELECT m.id
from Match m inner join ticket t on m.id=t.MID
where m.start_time>@date and t.status=0


INSERT INTO @availableMatches      SELECT c.name, c1.name, m.start_time, s.sname
FROM @matchid mi inner join Match m on(mi.ids=m.id) inner join club c on (m.cidH=c.id) inner join club c1 on(m.cidG=c1.id) inner join Stadium s on(s.id=m.sid)

return;
END;
go;



CREATE PROCEDURE acceptRequest
@SMusername varchar(20),
@hostingclubname varchar(20),
@competingclubname varchar(20),
@starttime datetime
AS
DECLARE @ID1 INT
DECLARE @ID2 INT
DECLARE @ID3 INT
DECLARE @ID4 INT
DECLARE @ID5 INT

SELECT @ID1=ID
FROM CLUB
WHERE @hostingclubname=NAME;

SELECT @ID2=ID
FROM CLUB
WHERE @competingclubname=NAME;

SELECT @ID3=ID FROM MATCH
WHERE @ID1= cidH AND @ID2=CIDG AND @starttime= start_time

SELECT @ID4=id
FROM Stadium_Manager
WHERE @SMusername=username

SELECT @ID5=id 
FROM Club_representative
WHERE @ID1 =cid


UPDATE Host_request
SET status='accepted'
WHERE match_id=@id3 and sid=@ID4 and @ID5=cid
go;


CREATE PROCEDURE rejectRequest
@stadiummanagerusername varchar(20),
@hostingclubname varchar(20),
@competingclubname varchar(20),
@starttime datetime
AS
DECLARE @ID1 INT
DECLARE @ID2 INT
DECLARE @ID3 INT
DECLARE @ID4 INT
DECLARE @ID5 INT

SELECT @ID1=ID
FROM CLUB
WHERE @hostingclubname=NAME;

SELECT @ID2=ID
FROM CLUB
WHERE @competingclubname=NAME;

SELECT @ID3=ID FROM MATCH
WHERE @ID1= cidH AND @ID2=CIDG AND @starttime= start_time

SELECT @ID4=id
FROM Stadium_Manager
WHERE @stadiummanagerusername=username

SELECT @ID5=id 
FROM Club_representative
WHERE @ID1 =cid


UPDATE Host_request
SET status='rejected'
WHERE match_id=@id3 and sid=@ID4 and @ID5=cid

GO;



CREATE PROC purchaseTicket
@nationalid int,
@hostingclubname varchar(20),
@competingclubname varchar(20),
@starttime datetime
AS
DECLARE @ID1 INT
DECLARE @ID2 INT
DECLARE @ID3 INT
DECLARE @ticketID int

SELECT @ID1=ID
FROM CLUB
WHERE @hostingclubname=NAME;

SELECT @ID2=ID
FROM CLUB
WHERE @competingclubname=NAME;

SELECT @ID3=ID FROM MATCH
WHERE @ID1= cidH AND @ID2=CIDG

SELECT @ticketID=t.id
from ticket t
where @ID3=MID

UPDATE TICKET
SET status=1
WHERE @ticketID=id




INSERT INTO TICKET_BUYING_TRANSACTIONS VALUES(@nationalid,@ticketID)
GO;

CREATE PROC updateMatchHost
@hostingclubname varchar(20),
@competingclubname varchar(20),
@starttime datetime
AS
DECLARE @ID1 INT
DECLARE @ID2 INT

SELECT @ID1=ID
FROM CLUB
WHERE @hostingclubname=NAME;

SELECT @ID2=ID
FROM CLUB
WHERE @competingclubname=NAME;

UPDATE  MATCH
SET cidH =@ID2 ,cidg = @id1
where cidh=@id1 and cidg=@id2

go;
CREATE FUNCTION [clubsNeverPlayed]
(@clubname varchar(20))
returns @x table(club varchar(20))

AS BEGIN
DECLAre @name varchar(20)
DECLARE @club1id INT
DECLARE @resultid table(id int)
DECLARE @c table(h  varchar(20))


select @club1id=id
from club
where name=@clubname

INSERT INTO @resultid  
select id
from Match m2
where @club1id=m2.cidH AND NOT EXISTS
(select m.cidG
from Match m
where @club1id=m.cidH and m.id=m2.id) AND
@club1id=m2.cidG AND NOT EXISTS
(select m3.cidH
from Match m3
where @club1id=m3.cidG and m3.id=m2.id)

INSERT INTO @x
SELECT c.name from @resultid r inner join club c on r.id=c.id 

return;
end;

GO;

CREATE FUNCTION[requestsFromClub]
(@SNAME varchar(20), @cname varchar(20))
returns @Ebada table( n1 varchar(20),n2 varchar(20))
AS
BEGIN
DECLARE @RID int
DECLARE @CID int
DECLARE @SID INT

SELECT @CID=id
from Club c
where @cname=name

select @RID=id 
from Club_representative
where @CID=cid

select @sid=s.id
from Stadium s
where @SNAME=s.sname

INSERT INTO @Ebada      SELECT m.cidH, m.cidG
from Host_request h inner join Match m on(h.match_id=m.id)
where @RID=h.cid and @SID=h.sid
return;
end;
go;
Create function [allUnassignedMatches] 
(@clubname varchar(20)) 
Returns @t table (
	name varchar(20),
	starttime datetime
	)

AS BEGIN
	declare @hostid int
	declare @guestid table(id int)
	declare @matchid int
	

	select @hostid = id from Club
	where name = @clubname

	INSERT INTO @guestid select m.cidG
	from Match m
	where m.cidH = @hostid and m.sid is null

	INSERT INTO @t select c.name, m.start_time
		from @guestid g inner join Club c on(g.id=c.id) inner join Match m on (g.id=m.cidG and m.cidH=@hostid)
		
	return;

	
end;

go;
CREATE FUNCTION[allPendingRequests]
(@username varchar(20))
returns @basma table (
clubrepname varchar(20),
guestclub varchar(20),
starttime datetime )
AS BEGIN
DECLARE @managerID int
DECLARE @repID table(ID int)
DECLARE @clubID table (id int)
DECLARE @matchID table(ids int)

SELECT @managerID=s.id
from Stadium_Manager s
where s.username=@username

INSERT INTO @repID 
SELECT h.cid 
from Host_request h
where @managerID=h.sid and h.status='unhandled'

INSERT INTO @matchID
SELECT h.match_id
from Host_request h
where h.sid=@managerID and h.status='unhandled'

INSERT INTO @clubID
SELECT m.cidG
from Match m inner join @matchID mi on(m.id=mi.ids)

INSERT INTO @basma
SELECT  cr.cname as representative , c.name as competing,m.start_time 
FROM @repID r inner join Club_representative cr on(r.ID=cr.id) inner join Match m on(r.ID=m.cidH) inner join @clubID ci on(ci.id=m.cidG) inner join Club c on(c.id=ci.id)

return;

end;
go;
Create function [viewAvailableStadiumsOn] 
(@x datetime) 
Returns @t table (
	name varchar(20),
	location varchar(20),
	capacity int)

AS BEGIN
	
	INSERT INTO @t  	select s.sname, s.location, s.capacity
				from Stadium as s 
				where not exists
				(
				select s1.id
				from Stadium as s1, Match as m1 
				where s1.id = m1.sid and @x > m1.start_time and @x < m1.end_time and s1.id=s.id
				)
			 return ;
end;

go;
create procedure addHostRequest
@cname varchar(20),
@sname varchar(20),
@stime datetime
AS
Declare @clubid int
Declare @stid int
Declare @matchid int



		Select @clubid = id from Club
		Where name=@cname

		Select @stid = id from Stadium
		Where sname=@sname

		Select @matchid = id from Match
		Where cidH = @clubid and sid = @stid and start_time = @stime 
		INSERT INTO Host_request VALUES (null, @matchid, @clubid, @stid)

go;
CREATE VIEW matchesPerTeam
AS 
select c.name , count (m.id) as matches
from Club c inner join Match m on c.id=m.cidH or c.id=m.cidG
where CURRENT_TIMESTAMP>m.end_time group by c.name;


go;


CREATE FUNCTION [matchWithHighestAttendance]
(
)
RETURNS  @t table(hostclub varchar(20), guestclub varchar(20))
AS BEGIN
DECLARE @Matchid table(id int, numberOfTickets int)
DECLARE @noOfTickets int

SELECT @noOfTickets=max(t.id)
FROM Ticket t inner join Match m on(t.MID=m.id)
where t.status=0



INSERT INTO @Matchid
SELECT  m.id,   (count(t.id))
from Match m inner join Ticket t on (m.id=t.MID)
where t.status=0
group by m.id


INSERT INTO @t
SELECT c.name as hostName, c1.name as guestName
from @Matchid mi inner join Match m on(m.id=mi.id) inner join Club c on(c.id=m.cidH) inner join Club c1 on(c1.id=m.cidG)
where mi.numberOfTickets=@noOfTickets
return;
end;
go;
CREATE FUNCTION [matchesRankedByAttendance]
()
RETURNS  @t table(hostclub varchar(20), guestclub varchar(20))

AS BEGIN
	declare @t1 table(matchid int, TicketSold int)

	insert into @t1
	select m.id, count(t.MID) as TicketSold
	from Match m, Ticket t 
	where m.id = t.MID and t.status = 1
	group by m.id

	insert into @t
	select (select c.name from club c where c.id = m.cidH), (select c.name from club c where c.id = m.cidG)
	from @t1 t1, Match m
	where t1.matchid = m.id
	order by t1.TicketSold

	return;
end;

go;
CREATE VIEW clubsNeverMatched
AS 
SELECT c.name AS firstClub, c1.name AS secondClub
FROM Club c ,Club c1
WHERE c.id<>c1.id and NOT EXISTS(
SELECT c2.id,c3.id
from Club c2 inner join Match m1 on(c2.id=m1.cidG or c2.id=m1.cidH) inner join Club c3 on(m1.cidG=c3.id or m1.cidH=c3.id)
where c2.id= c.id and c3.id=c1.id)


go;
