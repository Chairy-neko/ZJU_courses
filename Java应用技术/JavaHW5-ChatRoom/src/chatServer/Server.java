package chatServer;

import java.io.*;
import java.net.*;
import java.util.*;

/**
 * 
 * FileName: Server.java
 * 
 * Server code
 *
 * 
 * 
 * @author neko
 * @Date 01/14/2021
 * 
 * @version 1.01
 * 
 */

public class Server {
	private ServerSocket ss;
	private boolean serverFlag = false;//Determine whether the server is started successfully
	private Map<String, ServerClient> clients = new HashMap<>();//Store connected clients
	private static int clientNumber = 0;//Number of currently connected clients

	public static void main(String args[]) {
		new Server().start();
	}

	public void start() {
		try {
			ss = new ServerSocket(8888);
			serverFlag = true;
			System.out.println("启动服务器...");
		} catch (BindException e) {
			System.out.println("端口8888被占用");
		} catch (IOException e) {
			e.printStackTrace();
		}
		try {
			//Receive client connection
			while (serverFlag) {
				Socket socket = ss.accept();
				ServerClient c = new ServerClient(socket);
				clientNumber++;
				System.out.println(clientNumber + "个客户端已经连接");
				new Thread(c).start();
			}
		} catch (IOException e) {
			System.out.println("客户端关闭");
		} finally {
			try {
				if (ss != null)
					ss.close();
			} catch (IOException e) {
				e.printStackTrace();
			}
		}

	}

	private class ServerClient implements Runnable {
		private Socket s;
		private String userName = "";
		private DataInputStream input = null;
		private DataOutputStream output = null;
		private boolean connected = false;
		private BufferedOutputStream fout = null;
		private String saveFilePath = "";

		public ServerClient(Socket s) {
			this.s = s;
			try {
				input = new DataInputStream(s.getInputStream());
				output = new DataOutputStream(s.getOutputStream());
				connected = true;
			} catch (IOException e) {
				e.printStackTrace();
			}
		}

		@Override
		public void run() {
			byte buffer[] = new byte[1024];
			int len = 0;
			try {
				while (connected) {
					String msg[] = input.readUTF().split("#");// msg={指令,"用户","要发送的信息"}
					switch (msg[0]) {
					case "LOGIN":
						String userName = msg[1];
						if (clients.containsKey(userName)) {//If the user is already in the Client
							output.writeUTF("FAIL");
							System.out.println("拒绝了一个重复连接");
							clientNumber--;
							closeConnect();
						} else {
							output.writeUTF("SUCCESS");
							clients.put(userName, this);
							//send the info of all logged user to the new user
							StringBuffer allUsers = new StringBuffer();
							allUsers.append("ALLUSERS#");
							for (String user : clients.keySet())
								allUsers.append(user + "#");
							output.writeUTF(allUsers.toString());
							//Send the newly logged-in user information to other users
							String newLogin = "LOGIN#" + userName;
							sendMsg(userName, newLogin);
							this.userName = userName;
						}
						break;
					case "LOGOUT":
						clients.remove(this.userName);
						String logoutMsg = "LOGOUT#" + this.userName;
						sendMsg(this.userName, logoutMsg);
						System.out.println("用户" + this.userName + "已下线...");
						clientNumber--;
						if (clientNumber != 0)
							System.out.println(clientNumber + "个客户端已经连接...");
						else
							System.out.println("当前无客户端连接");
						closeConnect();
						break;
					case "SENDONE"://send message to one user
						ServerClient c = clients.get(msg[1]);//Get the connection of the target user
						String msgToOne = "";
						if (c != null) {
							msgToOne = "SENDONE#" + this.userName + "#" + msg[2];
							c.output.writeUTF(msgToOne);
							c.output.flush();
						}
						break;
					case "SENDALL"://send message to all user
						String msgToAll = "";
						msgToAll = "SENDALL#" + this.userName + "#" + msg[1];
						sendMsg(this.userName, msgToAll);
						break;

					}

				}
			} catch (IOException e) {
				System.out.println("Client closed...");
				connected = false;
			} finally {

				try {
					if (input != null)
						input.close();
					if (output != null)
						output.close();
					if (fout != null)
						fout.close();
					if (s != null)
						s.close();
				} catch (IOException e) {
					e.printStackTrace();
				}

			}
		}

		public void closeConnect() {
			connected = false;
			try {
				if (input != null)
					input.close();
				if (output != null)
					output.close();
				if (s != null)
					s.close();
			} catch (IOException e) {
				e.printStackTrace();
			}
		}

		public void sendMsg(String fromUser, String msg) {
			String tempUser = "";
			try {
				for (String toUser : clients.keySet()) {
					if (!toUser.equals(fromUser)) {
						tempUser = toUser;
						DataOutputStream out = clients.get(toUser).output;
						out.writeUTF(msg);
						out.flush();
					}
				}
			} catch (IOException e) {
				System.out.println("用户" + tempUser + "已经离线！！！");
			}
		}
	}
}
