#define _CRT_SECURE_NO_WARNINGS
#define _WINSOCK_DEPRECATED_NO_WARNINGS
#define _CRT_NONSTDC_NO_DEPRECATE
#include <sys/types.h>
#include <winsock2.h> 
#include <errno.h>
#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <string.h>
#include <signal.h>
#include <cstring>
#include <fstream>
#include <iomanip>
#include <iostream>
#include <sstream>
#include <WS2tcpip.h>
using namespace std;

#ifndef _UNISTD_H 
#define _UNISTD_H 
#include <io.h> 
#include <process.h> 
#endif

#pragma comment(lib,"ws2_32.lib")
#pragma comment(lib, "pthreadVC2.lib")
#pragma comment(lib, "pthreadVCE2.lib")
// the size of listen quene is 10
#define LISTEN_SIZE 10
// the port of the server csocket is 2095
#define SERVER_PORT 2095
#define MAXDATALEN 256

//packet and request
typedef enum { REQUEST = 1, RESPONSE, INSTRUCT } packetType;
typedef enum { TIME = 1, NAME, LIST, MESSAGE, DISCONNECT } requestType;
typedef enum { CORRECT = 1, WRONG, OVER } responseType;
typedef enum { FORWARD = 1, TERMINATE } instructType;

typedef struct spacket {
	packetType pType;
	int type;
	char data[MAXDATALEN];
} packet;

// the array to store socketfd of client, if no connect the element will be 0
struct client_fd
{
	int tail;
	int fd[LISTEN_SIZE];
}cfd;

struct client_list
{
	int fd;
	unsigned short port;
	struct in_addr addr;
}clt[LISTEN_SIZE];

int server_fd;


// lock
pthread_mutex_t mutex = PTHREAD_MUTEX_INITIALIZER;

// exit
static void myExitHandler(int signum);

// if success return 0 if fail return -1
void myAccept();

// use the new client fd to create the new pthread to handle the connect
int createConnectPthread();

// the function to handle the new connect
void* handleConnect(void*);

//after socket connect succeed, server send a packet to ensure
void sendHelloPacket(int fd);

void sendExitPacket(int fd);

// analysis the packet and make response
int handlePacket(packet* get_packet, int fd);

// use this function to response each type of request
void handleTimePacket(packet* get_packet, int fd);
void handleNamePacket(packet* get_packet, int fd);
void handleListPacket(packet* get_packet, int fd);
void handleMessagePacket(packet* get_packet, int fd);
int handleDisconnectPacket(packet* get_packet, int fd);

int main()
{
	WORD wVersionRequested;
	WSADATA wsaData;
	int ret, nLeft, length;

	wVersionRequested = MAKEWORD(2, 2);
	ret = WSAStartup(wVersionRequested, &wsaData);
	if (ret != 0)
	{
		cout << "[Server] WSAStartup() failed!" << endl;
		return 0;
	}
	if (LOBYTE(wsaData.wVersion) != 2 || HIBYTE(wsaData.wVersion) != 2)
	{
		WSACleanup();
		cout << "[Server] Invalid Winsock version!" << endl;
		return 0;
	}

	int struct_len;
	struct sockaddr_in server_addr;

	signal(SIGINT, myExitHandler);
	cout << "[Server] Service Initialize!" << endl;

	// init the array of client socketfd
	cfd.tail = 0;
	memset(cfd.fd, LISTEN_SIZE, 0);
	for (int i = 0; i < LISTEN_SIZE; i++)
		clt[i].fd = 0;

	// init the attribute of sockaddr_in to create new server socket
	server_addr.sin_family = AF_INET;
	server_addr.sin_port = htons(SERVER_PORT);
	server_addr.sin_addr.s_addr = htonl(INADDR_ANY);//inet_addr("10.71.45.98")
	memset(&(server_addr.sin_zero), 0, 8);
	struct_len = sizeof(struct sockaddr_in);

	// generate the new server fd
	server_fd = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);

	if (server_fd == INVALID_SOCKET)
	{
		WSACleanup();
		cout << "[Server] socket() failed!" << endl;
		return 0;
	}
	int reuse = 1;
	if (setsockopt(server_fd, SOL_SOCKET, SO_REUSEADDR, (const char*)&reuse, sizeof(reuse)))
	{
		cout << "[Server] setsockopt failed" << endl;
		exit(1);
	}
	// bind the server socket 
	if (bind(server_fd, (struct sockaddr*) & server_addr, struct_len) < 0) {
		// bind error output the error info and exit the server
		cout << "[Server] Bind ERROR!" << endl;
		return 0;
	}
	cout << "[Server] Bind Service Start!" << endl;
	// listen the client connect 
	if (listen(server_fd, LISTEN_SIZE) < 0) {
		cout << "[Server] Listen ERROR!" << endl;
		return 0;
	}
	cout << "[Server] Listen Service Start!" << endl;
	cout << "[Server] Service Start!" << endl;
	while (1) {
		myAccept();
	}

}

static void myExitHandler(int sig)
{
	pthread_mutex_lock(&mutex);
	for (int i = 0; i < LISTEN_SIZE; i++) {
		if (clt[i].fd > 0) {
			sendExitPacket(clt[i].fd);
			cout << "[Server] sockfd:" << clt[i].fd << " Connect Close!" << endl;
			close(clt[i].fd);
			clt[i].fd = 0;
		}
	}
	pthread_mutex_unlock(&mutex);
	close(server_fd);
	cout << "[Server] Exit!" << endl;
	exit(0);
}

//if accept success will create a pthread to handle the connect
void myAccept()
{
	int temp_fd, struct_len;
	struct sockaddr_in client_addr;
	int is_cfd_full;

	struct_len = sizeof(struct sockaddr_in);
	if (cfd.tail < LISTEN_SIZE) {
		int temp = accept(server_fd, (struct sockaddr*) & client_addr, &struct_len);
		pthread_mutex_lock(&mutex);
		cfd.fd[cfd.tail] = temp;
		cfd.tail++;
		is_cfd_full = 1;
		for (int i = 0; i < LISTEN_SIZE; i++) {
			if (clt[i].fd == 0) {
				clt[i].fd = cfd.fd[cfd.tail - 1];
				clt[i].port = client_addr.sin_port;
				clt[i].addr = client_addr.sin_addr;
				cout << "[Server] Sockfd:" << cfd.fd[cfd.tail - 1];
				cout << " Port:" << clt[i].port;
				cout << " IP:" << inet_ntoa(clt[i].addr);
				cout << " is Connecting!" << endl;
				is_cfd_full = 0;
				break;
			}
		}
		if (is_cfd_full) {
			cout << "[Server] socketfd:" << cfd.fd[cfd.tail - 1] << " Connect Failed!" << endl;
		}
		else {
			cout << "[Server] socketfd:" << cfd.fd[cfd.tail - 1] << " Connect Succeed!" << endl;
			createConnectPthread();
		}
		pthread_mutex_unlock(&mutex);

	}
	else {
		cout << "[Server] Client Connect is full!" << endl;
	}

}

//to create a new pthread for each socket connect
int createConnectPthread()
{
	pthread_attr_t attr;
	pthread_t tid;

	pthread_attr_init(&attr);
	//printf("attr init succeed!\n");
	pthread_create(&tid, &attr, handleConnect, (void*)NULL);
	//printf("create succeed!\n");

	return 0;
}

//use this function to handle each socket connect
void* handleConnect(void*)
{
	int fd, num_bytes;
	packet pkt;

	cout << "[Server] Start Get Connect Sockfd" << endl;
	// get the client fd from the cfd
	pthread_mutex_lock(&mutex);
	cfd.tail--;
	fd = cfd.fd[cfd.tail];
	pthread_mutex_unlock(&mutex);
	// after connect succeed send a packet to esure
	cout << "[Server] Get Connect Sockfd:" << fd << endl;
	//sendHelloPacket(fd);

	while (1) {

		num_bytes = recv(fd, (char*)&pkt, sizeof(pkt), 0);
		if (num_bytes < 0) {
			printf("[Server] from socketfd:%d Get Error Packet\n", fd);
			break;
		}
		cout << "[Server] from socketfd:" << fd << " Get Packet" << endl;
		cout << "[Server] from socketfd:" << fd << " pType:" << pkt.pType << " type:" << pkt.type << " data:" << pkt.data << endl;
		if (handlePacket(&pkt, fd) == -1) {
			return NULL;
		}

	}

}

/*
 * after socket connect succeed, server send a packet to ensure
 */
void sendHelloPacket(int fd)
{
	packet hello_packet;

	hello_packet.pType = RESPONSE;
	hello_packet.type = CORRECT;
	cout << "[Server] Start Generate hello packet data" << endl;
	sprintf(hello_packet.data, "[Server] socketfd:%d Connect Succeed!\n", fd);
	cout << "[Server] Generate hello packet data Succeed" << endl;
	send(fd, (char*)&hello_packet, sizeof(hello_packet), 0);
}

void sendExitPacket(int fd)
{
	packet exit_packet;

	exit_packet.pType = INSTRUCT;
	exit_packet.type = TERMINATE;
	sprintf(exit_packet.data, "[Server] Server Closed!\n");
	send(fd, (char*)&exit_packet, sizeof(exit_packet), 0);
	cout << "[Server] pType:" << exit_packet.pType << " type:" << exit_packet.type << " sockfd:" << fd << " Connect Close!" << endl;
}

/*
 *	to analysis the packet and make response
 */
int handlePacket(packet* get_packet, int fd)
{

	if (get_packet->pType == REQUEST) {
		requestType r_type = (requestType)get_packet->type;
		if (r_type == TIME) {
			handleTimePacket(get_packet, fd);
		}
		else if (r_type == NAME) {
			handleNamePacket(get_packet, fd);
		}
		else if (r_type == LIST) {
			handleListPacket(get_packet, fd);
		}
		else if (r_type == MESSAGE) {
			handleMessagePacket(get_packet, fd);
		}
		else if (r_type == DISCONNECT) {// handle client quit and close socket
			return handleDisconnectPacket(get_packet, fd);
		}
		else {
			cout << "[Server] Error REQUEST Type!" << endl;
		}
	}
	else if (get_packet->pType == RESPONSE) {
		cout << "[Server] Can't Receive RESPONSE Packet!" << endl;
	}
	else if (get_packet->pType == INSTRUCT) {
		cout << "[Server] Can't Receive INSTRUCT Packet!" << endl;
	}
	else {
		cout << "[Server] Error Packet!" << endl;
	}
	packet s_packet;
	s_packet.pType = RESPONSE;
	s_packet.type = OVER;
	send(fd, (char*)&s_packet, sizeof(s_packet), 0);
	return 0;
}

/*
 * generate the response packet for time request
 */
void handleTimePacket(packet* get_packet, int fd)
{
	packet s_packet;
	time_t t;
	struct tm* lt;
	time(&t);
	lt = localtime(&t);
	int i;

	int num_bytes = sprintf(s_packet.data, "[Server] Date:%d/%d/%d Time:%d:%d:%d\n", lt->tm_year + 1900, lt->tm_mon + 1, lt->tm_mday, lt->tm_hour, lt->tm_min, lt->tm_sec);
	s_packet.pType = RESPONSE;
	s_packet.type = CORRECT;

	send(fd, (char*)&s_packet, sizeof(s_packet), 0);

	return;
}

/*
 * generate the response packet for name request
 */
void handleNamePacket(packet* get_packet, int fd)
{
	packet s_packet;
	char host_name[128];
	int res = gethostname(host_name, sizeof(host_name));
	sprintf(s_packet.data, "[Server] Server Name: %s\n", host_name);
	s_packet.pType = RESPONSE;
	s_packet.type = CORRECT;
	send(fd, (char*)&s_packet, sizeof(s_packet), 0);
	return;
}

/*
 * generate the response packet for List request
 */
void handleListPacket(packet* get_packet, int fd)
{
	packet s_packet;
	s_packet.pType = RESPONSE;
	s_packet.type = CORRECT;

	pthread_mutex_lock(&mutex);
	int j = 0;
	for (int i = 0; i < LISTEN_SIZE; i++) {
		if (clt[i].fd > 0) {
			j += sprintf(s_packet.data + j, "[Server] Sockfd:%d ", clt[i].fd);
			j += sprintf(s_packet.data + j, "Port:%hu ", clt[i].port);
			j += sprintf(s_packet.data + j, "IP:%s\n", inet_ntoa(clt[i].addr));
		}
	}
	pthread_mutex_unlock(&mutex);
	send(fd, (char*)&s_packet, sizeof(s_packet), 0);
	return;
}

/*
 * generate the response packet for Message request
 */
void handleMessagePacket(packet* get_packet, int fd)
{
	packet s_packet;

	int des_fd = *((int*)get_packet->data);// need to test
	int isExist = 0;
	cout << "[Server] source_fd:"<< fd <<" destination_fd:"<<des_fd<< endl;
	pthread_mutex_lock(&mutex);
	for (int i = 0; i < LISTEN_SIZE; i++) {
		if (clt[i].fd == des_fd) {
			isExist = 1;
			break;
		}
	}
	pthread_mutex_unlock(&mutex);
	if (isExist == 1) {
		cout << "[Server] sockfd:" << fd << " Send Message to sockfd:" << des_fd << " Starts!" << endl;
		cout << "[Server] Message in Packet:" << get_packet->data + sizeof(int) << endl;
		s_packet.pType = INSTRUCT;
		s_packet.type = FORWARD;
		sprintf(s_packet.data, "[Server] %s from client sockfd %d\n", get_packet->data + sizeof(int), fd);
		send(des_fd, (char*)&s_packet, sizeof(s_packet), 0);
		packet r_packet;
		r_packet.pType = RESPONSE;
		r_packet.type = CORRECT;
		sprintf(r_packet.data, "[Server] Message to socketfd:%d Send Succeed!\n", des_fd);
		send(fd, (char*)&r_packet, sizeof(r_packet), 0);
	}
	else {
		s_packet.pType = RESPONSE;
		s_packet.type = CORRECT;
		int num_bytes = sprintf(s_packet.data, "[Server] No destination_fd:%d\n", des_fd);
		send(fd, (char*)&s_packet, sizeof(s_packet), 0);
	}
	return;
}

/*
 * update the clt for disconnect request
 */
int handleDisconnectPacket(packet* get_packet, int fd)
{
	cout << "[Server] Disconnect socketfd:" << fd << endl;
	pthread_mutex_lock(&mutex);
	for (int i = 0; i < LISTEN_SIZE; i++) {
		if (clt[i].fd == fd) {
			clt[i].fd = 0;
			break;
		}
	}
	pthread_mutex_unlock(&mutex);
	close(fd);
	return -1;
}



