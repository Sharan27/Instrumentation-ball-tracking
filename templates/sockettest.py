# # Import socket module 
# import socket			 

# # Create a socket object 
# s = socket.socket()		 

# # Define the port on which you want to connect 
# port = 80			

# # connect to the server on local computer 
# s.connect(('192.168.1.9', port)) 

# # receive data from the server and decoding to get the string.
# print (s.recv(1024).decode())
# # close the connection 
# s.close()	 
	
# first of all import the socket library 
import socket			 

# next create a socket object 
s = socket.socket()		 
print ("Socket successfully created")

port = 80			

s.bind(('192.168.1.9', port))		 
print ("socket binded to %s" %(port)) 

# put the socket into listening mode 
s.listen(5)	 
print ("socket is listening")		 

# a forever loop until we interrupt it or 
# an error occurs 
while True: 

# Establish connection with client. 
    c, addr = s.accept()	 
    print ('Got connection from', addr )

# send a thank you message to the client. encoding to send byte type. 
    c.send('Thank you for connecting'.encode()) 

# Close the connection with the client 
    c.close()

# Breaking once connection closed
    break
