#define _CRT_SECURE_NO_WARNINGS
#define _WINSOCK_DEPRECATED_NO_WARNINGS
#define _CRT_NONSTDC_NO_DEPRECATE
#include <cstring>
#include <fstream>
#include <iomanip>
#include <iostream>
#include <sstream>
#include <WS2tcpip.h>
#include <winsock2.h>
#include <pthread.h> 
//#include <unistd.h>

#ifndef _UNISTD_H 
#define _UNISTD_H 
#include <io.h> 
#include <process.h> 
#endif

using namespace std;
#define PORT 2095
#pragma comment(lib,"ws2_32.lib")
#pragma comment(lib, "pthreadVC2.lib")

#define MAXDATALEN 256

typedef enum { REQUEST = 1, RESPONSE, INSTRUCT } packetType;
typedef enum { TIME = 1, NAME, LIST, MESSAGE, DISCONNECT } requestType;
typedef enum { CORRECT = 1, WRONG, OVER } responseType;
typedef enum { FORWARD = 1, TERMINATE } instructType;

typedef struct spacket {
	packetType pType;
	int type;
	char data[MAXDATALEN];
} packet;
int counter = 0, flag = 0;
void* waitServer(void* socketfd) {
	packet pkt;
	while (true) {
		memset(pkt.data, 0, sizeof(pkt.data));       //check!
		recv(*(int*)socketfd, (char*)&pkt, sizeof(pkt), 0);
		if (pkt.type == OVER && pkt.pType == RESPONSE) {
			break;
		}
		if (pkt.type == TERMINATE && pkt.pType == INSTRUCT) {
			printf("(Client) Server connection terminated!\n");
			pthread_exit(0);
		}
		printf("%s\n", pkt.data);
		counter++;
		if (flag)break;

	}
	return NULL;
}

void sendDisRequestPacket(int socketfd) {
	packet pkt;
	pkt.pType = REQUEST;
	pkt.type = (int)DISCONNECT;
	memset(pkt.data, 0, sizeof(pkt.data));
	send(socketfd, (char*)&pkt, sizeof(pkt), 0);
}

void sendTimeRequestPacket(int socketfd) {
	packet pkt;
	pkt.pType = REQUEST;
	pkt.type = (int)TIME;
	memset(pkt.data, 0, sizeof(pkt.data));
	send(socketfd, (char*)&pkt, sizeof(pkt), 0);
}

void sendNameRequestPacket(int socketfd) {
	packet pkt;
	pkt.pType = REQUEST;
	pkt.type = (int)NAME;
	memset(pkt.data, 0, sizeof(pkt.data));
	send(socketfd, (char*)&pkt, sizeof(pkt), 0);
}

void sendListRequestPacket(int socketfd) {
	packet pkt;
	pkt.pType = REQUEST;
	pkt.type = (int)LIST;
	memset(pkt.data, 0, sizeof(pkt.data));
	send(socketfd, (char*)&pkt, sizeof(pkt), 0);
}

void sendMessageRequestPacket(int socketfd) {
	int destClient;
	packet pkt;
	pkt.pType = REQUEST;
	pkt.type = (int)MESSAGE;
	memset(pkt.data, 0, sizeof(pkt.data));

	printf("(Client) PLease input client id you want to send: ");
	scanf("%d", &destClient);
	memcpy(pkt.data, &destClient, sizeof(int));

	printf("(Client) PLease input message you want to send: ");
	getchar();//refresh buffer
	fgets(pkt.data + sizeof(int), MAXDATALEN - sizeof(int), stdin);

	send(socketfd, (char*)&pkt, sizeof(pkt), 0);
	printf("(Client) sending message to client %d\n", destClient);
}

int main() {

	WORD wVersionRequested;
	WSADATA wsaData;
	int err;
	wVersionRequested = MAKEWORD(1, 1);
	err = WSAStartup(wVersionRequested, &wsaData);
	if (err != 0)
	{
		perror("WSAStartup error");
	}

	int i, port;
	int socket_fd;
	//SOCKET socket_fd;
	char ip[16];
	pthread_t p;

	//initialization
	cout << " +-----------------------------------------------+" << endl;
	cout << " | 欢迎来到客户端，请选择以下操作：              |" << endl;
	cout << " +-----------------------------------------------+" << endl;
	cout << " | [1] 连接到指定地址和端口服务端                |" << endl;
	cout << " | [2] 断开与服务器的连接                        |" << endl;
	cout << " | [3] 请求服务端给出当前时间                    |" << endl;
	cout << " | [4] 请求服务端给出主机名                      |" << endl;
	cout << " | [5] 请求服务端给出当前连接的所有客户端信息    |" << endl;
	cout << " | [6] 请求服务端把消息转发给对应编号的客户端    |" << endl;
	cout << " | [7] 请求接受服务端转发的消息                  |" << endl;
	cout << " | [0] 断开连接并推出客户端程序                  |" << endl;
	cout << " +-----------------------------------------------+" << endl;
	



	cin >> i;
	while (true) {
		switch (i) {
		case 1:
			cout << "请输入服务器IP：";
			cin >> ip;
			//define socket client
			socket_fd = socket(AF_INET, SOCK_STREAM, 0);
			if (socket_fd == -1) {
				cout << "[Client] Defining socket_fd fails!" << endl;
			}

			//define socketaddr_in
			struct sockaddr_in in_addr;
			memset(&in_addr, 0, sizeof(in_addr));
			in_addr.sin_family = AF_INET;
			in_addr.sin_port = htons(PORT);  //server port
			in_addr.sin_addr.s_addr = inet_addr(ip);  //server IP

			//connect server
			cout << "[Client] Connecting..." << endl;
			if (connect(socket_fd, (struct sockaddr*) & in_addr, sizeof(in_addr)) < 0) {
				perror("connect");
				cout << "连接失败！请重新连接" << endl;
				break;
			}
			cout << "[Client] Connected successfully!" << endl;
			break;
		case 2:
			sendDisRequestPacket(socket_fd);
			break;
		case 3:
			counter = 0;
			//while(counter < 100)
			//{
				sendTimeRequestPacket(socket_fd);
				waitServer(&socket_fd);
				printf("-------------count: %d--------------------\n", counter);
			//}
			break;
		case 4:
			sendNameRequestPacket(socket_fd);
			waitServer(&socket_fd);
			break;
		case 5:
			sendListRequestPacket(socket_fd);
			waitServer(&socket_fd);
			break;
		case 6:
			sendMessageRequestPacket(socket_fd);
			waitServer(&socket_fd);
			break;
		case 7:
			flag = 1;
			waitServer(&socket_fd);
			flag = 0;
			break;
		case 0:
			//pthread_cancel(p);
			sendDisRequestPacket(socket_fd);
			exit(0);
		}

		cin >> i;
	}

	return 0;
}

