package chatClient;

import java.awt.BorderLayout;
import java.awt.EventQueue;
import java.awt.Font;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

import javax.swing.JButton;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.JPasswordField;
import javax.swing.JTextField;
import javax.swing.WindowConstants;
import javax.swing.border.EmptyBorder;

public class LogWindow extends JFrame {
	private JPanel contentPane;
	private JTextField tf_uname;
	private JPasswordField passwordField;

    public LogWindow(){
    	//Render UI
    	try {
            for (javax.swing.UIManager.LookAndFeelInfo info : javax.swing.UIManager.getInstalledLookAndFeels()) {
                if ("Nimbus".equals(info.getName())) {
                    javax.swing.UIManager.setLookAndFeel(info.getClassName());
                    break;
                }
            }
        }catch(Exception e) {
        	System.out.println(e);
        }
        
        setTitle("\u767B\u5F55");
		setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
		setBounds(100, 100, 300, 240);
		setResizable(false);
		contentPane = new JPanel();
		contentPane.setBorder(new EmptyBorder(5, 5, 5, 5));
		contentPane.setLayout(null);
		setContentPane(contentPane);
		
		tf_uname = new JTextField();
		tf_uname.setBounds(110, 43, 120, 30);
		contentPane.add(tf_uname);
		tf_uname.setColumns(10);
		
		passwordField = new JPasswordField();
		passwordField.setBounds(110, 93, 120, 30);
		contentPane.add(passwordField);
		
		JLabel lbl_uname = new JLabel("\u7528\u6237\u540D");
		lbl_uname.setFont(new Font("宋体", Font.PLAIN, 14));
		lbl_uname.setBounds(50, 49, 60, 20);
		contentPane.add(lbl_uname);
		
		JLabel lbl_pwd = new JLabel("\u5BC6  \u7801");
		lbl_pwd.setFont(new Font("宋体", Font.PLAIN, 14));
		lbl_pwd.setBounds(50, 99, 60, 20);
		contentPane.add(lbl_pwd);
		
		JButton btnLog = new JButton("\u767B\u5F55");
		btnLog.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {

//				setVisible(false);
			}
		});
		btnLog.setBounds(55, 150, 70, 30);
		contentPane.add(btnLog);
		
		JButton btnRegister = new JButton("\u6CE8\u518C");
		btnRegister.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				System.out.println("注册成功！");
//				setVisible(false);
			}
		});
		btnRegister.setBounds(160, 150, 70, 30);
		contentPane.add(btnRegister);
    }

}
