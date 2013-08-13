import java.net.*;
import java.io.*;
import java.util.*;

/**
 * The minivas class manages interactions with the pVAS server. 
 **/
public class minivas {
	private Socket s;
	private BufferedWriter out;

	private String HOST;
	private int PORT;

	/**
	 * Default constructor.
	 * Loads host information from minivas.pref in working directory.
	 **/
	public minivas() {
		try {
			File f = new File("minivas.pref");
			FileInputStream fis = new FileInputStream(f);
			BufferedReader br = new BufferedReader(new InputStreamReader(fis));
			String str = br.readLine();
			while (str != null) {
				StringTokenizer stk = new StringTokenizer(str);
				if (stk.countTokens() >= 2) {
					String key = stk.nextToken().toLowerCase();
					if (key.equals("host")) {
						HOST = stk.nextToken();
					} else if (key.equals("port")) {
						PORT = Integer.parseInt(stk.nextToken());
					}
				}
				str = br.readLine();
			}
		} catch (Exception exc) {
			exc.printStackTrace();
		}
		connect();
	}

	/**
     * Connects to pVAS at specified host and port
	 *
	 * @param	host	hostname or host IP
	 * @param	port	destination port
     **/
	public minivas(String host, int port) {
		HOST = host;
		PORT = port;
	}

	private void connect() {
		try {
			s = new Socket(HOST, PORT);
			out = new BufferedWriter(
				new OutputStreamWriter(s.getOutputStream())
			);
		} catch (Exception exc) {
			exc.printStackTrace();
		}	
	}
	
	/**
	 * Disconnect from pVAS server
	 *
	 * @return	false if communication error
	 **/
	public boolean disconnect() {
		try {
			out.close();
			s.close();
		} catch (Exception exc) {
			exc.printStackTrace();
			return false;
		}
		return true;
	}

	/**
	 * Disconnect from pVAS server and tell the server to quit
	 *
	 * @return	false if communication error
	 **/
	public boolean kill() {
		if (!send("quit")) return false;
		disconnect();
		return true;
	}

	/**
	 * Sets flow rate for specified channel
	 *
	 * @param	channel		channel number (between 1 and 30)
	 * @param	flowRate	flow rate (between 0 and 400)
	 * @return	false if communication error
	 **/
	public boolean setChannel(int channel, int flowRate) {
		return send("setchannel " + channel + " " + flowRate);
	}

	/**
	 * Sets flow rate for all 30 channels on the miniVAS
	 *
	 * @param	flowRates	flow rates must be of length 30
	 * @return	false if incorrect flowRates length or communication error
	 **/
	public boolean setChannels(int[] flowRates) {
		if (flowRates.length != 30) return false;
		String cmd = "setchannel ";
		for (int i=0; i<flowRates.length; i++) {
			cmd += (i+1) + " " + flowRates[i] + " ";
		}
		return send(cmd);
	}

	/**
	 * Enables / disables the 30 miniVAS channels. '1' means
	 * to enable the channel, '0' means to disable.
	 *
	 * @param	enabled		array of enabled status
	 * @return	false if incorrent enabled length or communication error
	 **/
	public boolean setChannelsEnabled(int[] enabled) {
		if (enabled.length != 30) return false;
		String cmd = "setenabled ";
		for (int i=0; i<enabled.length; i++) {
			cmd += " " + enabled[i];
		}
		return send(cmd);
	}

	/**
	 * Sets flow rate to zero for all channels
	 *
	 * @return	false if communication error
	 **/
	public boolean allChannelsOff() {
		return send("zeroflow");
	}

	/**
	 * Tells Aroma Composer to load file with specified name
	 *
	 * @param	fileName	Name of file to load
	 * @return	false if communication error
	 **/
	public boolean loadFile(String fileName) {
		return send("loadfile " + fileName);
	}

	private boolean send(String cmd) {
		try {
			out.write(cmd);
			out.newLine();
			out.flush();
		} catch (Exception exc) {
			exc.printStackTrace();
			return false;
		}
		return true;
	}

	public static void main(String[] args) {
		minivas v = new minivas();
		v.setChannel(1,100);
		v.disconnect();
	}
}
