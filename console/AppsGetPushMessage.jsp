<%@ page language="java" contentType="text/html; charset=utf-8"%>
<%@ page
	import="java.sql.*,java.lang.String,java.util.Date,java.util.Calendar,java.text.SimpleDateFormat"%>
<%@ page import="java.io.File"%>
<%@ page import="java.io.BufferedReader"%>
<%@ page import="java.io.FileInputStream"%>
<%@ page import="java.io.InputStreamReader"%>
<%@ page import="java.util.Iterator"%>
<%@ page import="java.util.List"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.HashMap"%>
<%@ page import="org.apache.commons.fileupload.*"%>
<%@ page import="org.apache.commons.fileupload.disk.DiskFileItemFactory"%>
<%@ page
	import="org.apache.commons.fileupload.servlet.ServletFileUpload"%>
<%@ page import="org.apache.commons.io.FilenameUtils"%>
<%@ include file="/jsp/include/AuthenticationPage.jsp"%>
<%@ include file="/jsp/include/ConnectMCSPoolPage.jsp"%>
<%@ include file="/jsp/include/ConnPNCPoolPage.jsp"%>

<%@include file="AppsPushMessageCommon.jsp"%>

<%!//******** 變數宣告 ***********/
	private final boolean mbDebug = false;

	private final String PARAM_SELECT_APP = "SelectApp";
	private final String PARAM_SELECT_MAG_TYPE = "SelectMsgType";
	private final String PARAM_SELECT_BRAND = "SelectBrand";
	private final String PARAM_SELECT_MODEL = "SelectModel";
	private final String PARAM_MSG_NAME = "MsgName";
	private final String PARAM_SUBJECT = "Subject";
	private final String PARAM_MSG_CONTENT = "content";
	private final String PARAM_SEND_TYPE = "SendingType";
	private final String PARAM_YEAR = "Year";
	private final String PARAM_MONTH = "Month";
	private final String PARAM_DAY = "Day";
	private final String PARAM_HOUR = "Hour";
	private final String PARAM_MIN = "Min";
	private final String PARAM_CONTENT_TYPE = "content_type";
	private final String UPLOAD_FILE_PATH = "/uploadfile";

	private class SendDate {
		public String mstrYear = null;
		public String mstrMonth = null;
		public String mstrDay = null;
		public String mstrHour = null;
		public String mstrMinute = null;

		public SendDate() {
			setYear(null);
			setMonth(null);
			setDay(null);
			setHour(null);
			setMinute(null);
		}

		public SendDate(String strYear, String strMonth, String strDay,
						String strHour, String strMinute) {
			setYear(strYear);
			setMonth(strMonth);
			setDay(strDay);
			setHour(strHour);
			setMinute(strMinute);
		}

		public void setYear(String strYear) {
			if (strYear == null) {
				Date date = new Date();
				Calendar cal = Calendar.getInstance();
				cal.setTime(date);
				int year = cal.get(Calendar.YEAR);
				int month = cal.get(Calendar.MONTH);
				int day = cal.get(Calendar.DAY_OF_MONTH);
				mstrYear = String.format("%d", year + 1900);
			} else
				mstrYear = strYear;
		}

		public void setMonth(String strMonth) {
			if (strMonth == null) {
				Date date = new Date();
				Calendar cal = Calendar.getInstance();
				cal.setTime(date);
				int year = cal.get(Calendar.YEAR);
				int month = cal.get(Calendar.MONTH);
				int day = cal.get(Calendar.DAY_OF_MONTH);
				mstrMonth = String.format("%02d", month + 1);
			} else
				mstrMonth = String.format("%02d", Integer.parseInt(strMonth));
		}

		public void setDay(String strDay) {
			if (strDay == null) {
				Date date = new Date();
				Calendar cal = Calendar.getInstance();
				cal.setTime(date);
				int year = cal.get(Calendar.YEAR);
				int month = cal.get(Calendar.MONTH);
				int day = cal.get(Calendar.DAY_OF_MONTH);
				mstrDay = String.format("%02d", day);
			} else
				mstrDay = String.format("%02d", Integer.parseInt(strDay));
		}

		public void setHour(String strHour) {
			if (strHour == null) {
				Calendar rightNow = Calendar.getInstance();
				mstrDay = String.format("%02d",
						rightNow.get(Calendar.HOUR_OF_DAY));
				rightNow = null;
			} else
				mstrHour = String.format("%02d", Integer.parseInt(strHour));
		}

		public void setMinute(String strMinute) {
			if (strMinute == null) {
				Calendar rightNow = Calendar.getInstance();
				mstrMinute = String.format("%02d",
						rightNow.get(Calendar.MINUTE));
				rightNow = null;
			} else
				mstrMinute = String.format("%02d", Integer.parseInt(strMinute));
		}
	}%>

<%!//******** 函數宣告 **********/
	/*private String createIMEITable(String[] astrIMEI)
	{
		String strSelect = null;
		StringBuffer strResult = new StringBuffer();
		for(int i = 0; i < astrIMEI.length; ++i)
		{
			if(0 < strResult.length())
			{
				strResult.append("union ");
			}
			strSelect = String.format("select '%%%s%%' as c1 ",astrIMEI[i].trim() );
			strResult.append(strSelect);
			if(1 == astrIMEI.length)
			{
				strResult.append("union ");
				strResult.append(strSelect);
			}
		}
		
		return strResult.toString();
	}*/

	private String getDateSeq() {
		java.util.Date now = new java.util.Date();
		String strNow = new java.text.SimpleDateFormat("yyyyMMddHHmmssSS")
				.format(now);
		return strNow;
	}

	private static int mnThread_no = 1;
	private static int mnThread_Max = 10;
	private static int mnThread_Group = 10;
	%>

<%
	/** Initial Push Message Deliver Thread **/
	String strThread = getServletContext().getInitParameter("PUSH_MESSAGE_THREAD_MAX");
	if(null != strThread)
	{
		mnThread_Max = Integer.valueOf(strThread);
	}
	
	strThread = getServletContext().getInitParameter("PUSH_MESSAGE_THREAD_GROUP");
	if(null != strThread)
	{
		mnThread_Group = Integer.valueOf(strThread);
	}

	String strResult = "";
	StringBuffer strbufSelectApp = new StringBuffer();
	String[] straSelectApp = null;
	String[] astrIMEI = null;
	String strSelectMsgType = null;
	String strSelectBrand = null;
	String strSelectModel = null;
	String strMsgName = null;
	String strSubject = null;
	String strMsgContent = null;
	String strSendingType = null;
	String strContentType = null;
	SendDate sendDate = new SendDate();

	request.setCharacterEncoding("UTF-8");

	// Check that we have a file upload request
	boolean isMultipart = ServletFileUpload.isMultipartContent(request);
	if (mbDebug) {
		out.println("isMultipart=" + isMultipart + "<br>");
	}

	astrIMEI = null;
	if (isMultipart) {
		String saveDirectory = application
		.getRealPath(UPLOAD_FILE_PATH);
		// Create a factory for disk-based file items
		FileItemFactory factory = new DiskFileItemFactory();
		// Create a new file upload handler
		ServletFileUpload upload = new ServletFileUpload(factory);

		// Parse the request
		List<FileItem> items = upload.parseRequest(request);

		// Process the uploaded items
		Iterator<FileItem> iter = items.iterator();

		while (iter.hasNext()) {
			FileItem item = (FileItem) iter.next();
			if (item.isFormField()) {
				String strName = item.getFieldName();
				String strValue = item.getString();
				strValue = new String(strValue.getBytes("ISO-8859-1"), "UTF-8");

				if (PARAM_SELECT_APP.equals(strName)) {
					strbufSelectApp.append(strValue + ",");
				}
	
				if (PARAM_SELECT_MAG_TYPE.equals(strName)) {
					strSelectMsgType = strValue;
				}
	
				if (PARAM_SELECT_BRAND.equals(strName)) {
					strSelectBrand = strValue;
				}
	
				if (PARAM_SELECT_MODEL.equals(strName)) {
					strSelectModel = strValue;
				}
	
				if (PARAM_MSG_NAME.equals(strName)) {
					strMsgName = strValue;
				}
	
				if (PARAM_SUBJECT.equals(strName)) {
					strSubject = strValue;
				}
	
				if (PARAM_CONTENT_TYPE.equals(strName)) {
					strContentType = strValue;
				}
	
				if (PARAM_MSG_CONTENT.equals(strName)) {
					strMsgContent = strValue;
				}
	
				if (PARAM_SEND_TYPE.equals(strName)) {
					strSendingType = strValue;
				}
	
				if (PARAM_YEAR.equals(strName)) {
					sendDate.setYear(strValue);
				}
	
				if (PARAM_MONTH.equals(strName)) {
					sendDate.setMonth(strValue);
				}
	
				if (PARAM_DAY.equals(strName)) {
					sendDate.setDay(strValue);
				}
	
				if (PARAM_HOUR.equals(strName)) {
					sendDate.setHour(strValue);
				}
	
				if (PARAM_MIN.equals(strName)) {
					sendDate.setMinute(strValue);
				}
			} else {
			// Process a file upload
				String fieldName = item.getFieldName();
				String fileName = item.getName();
				String contentType = item.getContentType();
				boolean isInMemory = item.isInMemory();
				long sizeInBytes = item.getSize();
				if (mbDebug) {
					out.println("fieldName=" + fieldName + "<br>");
					out.println("fileName=" + fileName + "<br>");
					out.println("contentType=" + contentType + "<br>");
					out.println("isInMemory=" + isInMemory + "<br>");
					out.println("sizeInBytes=" + sizeInBytes + "<br>");
				}
				if (fileName != null && !"".equals(fileName)
					&& contentType.equals("text/plain")
					&& 0 < sizeInBytes) {
					StringBuffer bufstrTmp = new StringBuffer(
						item.getString());
					astrIMEI = bufstrTmp.toString().split("\n");
	
				//               fileName= FilenameUtils.getName(fileName);
				//               File uploadedFile = new File(saveDirectory, fileName);
				//               item.write(uploadedFile);
				//               out.println("fileName saved="+fileName+"<br>");
				}
			}
		} // while
		straSelectApp = strbufSelectApp.toString().split(",");
		strbufSelectApp.delete(0, strbufSelectApp.length());
	} else {
		//取得request資料
		straSelectApp = request.getParameterValues(PARAM_SELECT_APP);
		strSelectMsgType = request.getParameter(PARAM_SELECT_MAG_TYPE);
		strSelectBrand = request.getParameter(PARAM_SELECT_BRAND);
		strSelectModel = request.getParameter(PARAM_SELECT_MODEL);
		strMsgName = request.getParameter(PARAM_MSG_NAME);
		strSubject = request.getParameter(PARAM_SUBJECT);
		strMsgContent = request.getParameter(PARAM_MSG_CONTENT);
		strSendingType = request.getParameter(PARAM_SEND_TYPE);//1:即時,  0:預約
		sendDate = new SendDate(request.getParameter(PARAM_YEAR),
								request.getParameter(PARAM_MONTH),
								request.getParameter(PARAM_DAY),
								request.getParameter(PARAM_HOUR),
								request.getParameter(PARAM_MIN));
	}

	if (strSelectMsgType == null)
		strSelectMsgType = "";
	if (strSelectBrand == null)
		strSelectBrand = "";
	if (strSelectModel == null)
		strSelectModel = "";
	if (strMsgName == null)
		strMsgName = "";
	if (strSubject == null)
		strSubject = "";
	if (strMsgContent == null)
		strMsgContent = "";
	if (strSendingType == null)
		strSendingType = "1";

	if (null != astrIMEI) {
		strSelectBrand = "-1";
		strSelectModel = "-1";
	}

	if (mbDebug) {
		for (int i = 0; i < straSelectApp.length; ++i) {
			out.println("SelectApp = " + straSelectApp[i] + "<br>");
		}
		out.println("Message Type = " + strSelectMsgType + "<br>");
		out.println("Brand = " + strSelectBrand + "<br>");
		out.println("Model = " + strSelectModel + "<br>");
		out.println("Message Name = " + strMsgName + "<br>");
		out.println("Message Subject = " + strSubject + "<br>");
		out.println("Content Type = " + strContentType + "<br>");
		out.println("Message Content = " + strMsgContent + "<br>");
		out.println("Send Type = " + strSendingType + "<br>");
		out.println("Send Date = " + sendDate.mstrYear + " - "
		+ sendDate.mstrMonth + " - " + sendDate.mstrDay + " - "
		+ sendDate.mstrHour + " - " + sendDate.mstrMinute
		+ "<br>");
		if (null != astrIMEI) {
			out.println("IMEI of upload file:<br>");
			for (int i = 0; i < astrIMEI.length; ++i) {
				out.println(astrIMEI[i] + "<br>");
			}
		}
	}

	//確認取得資料並insert進資料庫
	if (straSelectApp != null && !strMsgContent.equals("")) {
		try {
			boolean isIAWA = false;
			int device_count = 0, x = 0;;
			StringBuffer sSql = new StringBuffer();
			StringBuffer sbSql = new StringBuffer();
			StringBuffer sbSubSql = new StringBuffer();
			String sScheduleDatetime = "";
			String sIsScheduled = "N";
			String[] sAppInfo = null;
			String sMsgId = "";
			Date now = new Date();
			SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
			String strTmp = String.format("<br>|======= %s 己完成推播設定結果 =======|<br>", sdf.format(now));
			strResult += strTmp;
			sdf = new SimpleDateFormat("yyyyMMddHHmmssSSS");

			if (strContentType.equals("html")
			|| strContentType.equals("canned")
			|| strContentType.equals("url")) //2014.09.09 Edited by Romeo 
			{
				isIAWA = true;
			}

			// ************ 新增IAWA推播訊息 ***************/
			if (isIAWA) {
				String strCannedSql = null;
				if (strContentType.equals("html")) {
				final String strContentId = getDateSeq();
				PreparedStatement prestmt = null;
				strCannedSql = "insert into senao_pushmessage_canned(content_id,msg_name,subject,content,create_by,create_date) " 
						       + "values(?,?,?,?,?,date_trunc('second', now()))";
				prestmt = conPNC.prepareStatement(strCannedSql);
				prestmt.setString(1, strContentId);
				prestmt.setString(2, strMsgName);
				prestmt.setString(3, strSubject);
				prestmt.setString(4, strMsgContent);
				prestmt.setString(5, userID);
				prestmt.executeUpdate();
				prestmt.close();
				strMsgContent = CONTENT_PATH + strContentId;
				}

				if (strContentType.equals("canned")) {
					Statement stmtCanned = null;
					ResultSet rsCanned = null;
					strCannedSql = "select * from senao_pushmessage_canned where content_id='"
							       + strMsgContent + "'";
					stmtCanned = conPNC.createStatement();
					rsCanned = stmtCanned.executeQuery(strCannedSql);
					rsCanned.next();
					strMsgName = rsCanned.getString("msg_name");
					strSubject = rsCanned.getString("subject");
					strMsgContent = CONTENT_PATH + strMsgContent;
				}
	
				if (strContentType.equals("url")
					&& strMsgContent.indexOf("?") == -1) { //2014.09.26 edited by romeo
					strMsgContent = strMsgContent + "?0=0";
				}
			}


			
			// ************ codes from here is by Strong ***************/
			/***2015/04/20 先將發送清單存入senao_pushmessage_imei***/
			//先清空senao_pushmessage_imei table的資料
			Statement sqlStmt = conPNC.createStatement(), sqlStmtMCS = conMCS.createStatement();
			PreparedStatement psqlStmt;
			StringBuffer strBuf = new StringBuffer();
			conPNC.setAutoCommit(true);
			sqlStmt.executeUpdate("vacuum full senao_pushmessage_pool;");
            conPNC.setAutoCommit(false);
		    sqlStmt.executeUpdate("ALTER SEQUENCE senao_pushmessage_imei_thread_no_seq RESTART WITH 1;");
			sqlStmt.execute("delete from senao_pushmessage_imei");
			conPNC.commit();
			//sqlStmt.close();

			if (astrIMEI != null) {
				//準備批次insert imei
		        psqlStmt = conPNC.prepareStatement("insert into senao_pushmessage_imei values (?)");
				for (int i = 0; i < astrIMEI.length; ++i) 
				{
					psqlStmt.setString(1, astrIMEI[i].trim());
					psqlStmt.addBatch();
					if ((i % 10000) == 0)
						psqlStmt.executeBatch();
				}
				psqlStmt.executeBatch();
				// psqlStmt.close();
			}
			
			// ************ 新增推播訊息 ***************/
			// ************ 新增推播傳送端 ***************/
			List<String> oslist  = new ArrayList<String>(),
						 uselist = new ArrayList<String>();
			String oskind = "", usefor = "", oskindtmp = "", usefortmp = "";
			int pgversion = 0;
			ResultSet rsVersion = null, rsPushcounts = null, rsRegistry = null;
			sMsgId = sdf.format(now);
			Timestamp currTsmp = new Timestamp((new java.util.Date()).getTime());
			psqlStmt = conPNC.prepareStatement("insert into senao_pushmessage (msg_id, os_kind, use_for, msg_name, msg_type, subject, content, is_pooling, pooling_date, " + 
			                                                                  "msg_action, is_scheduled, schedule_datetime, device_count, create_by, create_date) " +
											   "values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)");
			
			if (strSendingType.trim().equals("0")) //判斷是否有預約
			{
				sIsScheduled = "Y";
				sScheduleDatetime = sendDate.mstrYear
									+ sendDate.mstrMonth + sendDate.mstrDay
									+ sendDate.mstrHour
									+ sendDate.mstrMinute;
			}
			
			for (String val: straSelectApp) {
				usefortmp = val.substring(0, val.indexOf(':'));
				oskindtmp = val.substring(val.indexOf(':') + 1);
				if (!oslist.contains(oskindtmp)) {
					oskind = oskind + ((oskind == "")?"": ",") + "'" + oskindtmp + "'";
					oslist.add(oskindtmp);
				}
				if (!uselist.contains(usefortmp)) {
					usefor = usefor + ((usefor == "")?"": ",") + "'" + usefortmp + "'";
					uselist.add(usefortmp);
				}
				
				psqlStmt.setString(    1, usefortmp + sMsgId);
				psqlStmt.setString(    2, oskindtmp);
				psqlStmt.setString(    3, usefortmp);
				psqlStmt.setString(    4, strMsgName);
				psqlStmt.setString(    5, strSelectMsgType);
				psqlStmt.setString(    6, strSubject);
				psqlStmt.setString(    7, strMsgContent);
				psqlStmt.setString(    8, "Y");
				psqlStmt.setTimestamp( 9, currTsmp);
				psqlStmt.setString(   10, (isIAWA == true)?"IAWA":"VIEW");
				psqlStmt.setString(   11, sIsScheduled);
				psqlStmt.setString(   12, sScheduleDatetime);
				psqlStmt.setInt(      13, 0);
				psqlStmt.setString(   14, userName);
				psqlStmt.setTimestamp(15, currTsmp);
				psqlStmt.addBatch();
		    }
			
			psqlStmt.executeBatch();
			
			//sbSubSql.append("insert into senao_pushmessage_pool (device_id, msg_id,");
			//sbSubSql.append("device_token, use_for, os_kind, create_date, create_by, register_id, thread_no) ");
			sbSubSql.append("select device_id,");
			sbSubSql.append("use_for||'" + sMsgId + "' as msg_id, device_token,");
			//sbSubSql.append("use_for, os_kind, '" + userID + "', ");
			sbSubSql.append("use_for, os_kind, ");
			
			rsVersion = sqlStmt.executeQuery("select to_number(trim(substr(version(), 14, 2), '.')) as version");
			rsVersion.next();
			pgversion = rsVersion.getInt("version");
			if (pgversion >= 9)
			  sbSubSql.append(" (array_agg(register_id order by decode(register_id, '', to_date('19110101','YYYYMMDD'), create_date) desc))[1]  register_id, ");
			else
			  sbSubSql.append("max(register_id)  register_id, ");
			
			sbSubSql.append("decode(mod(ceil((dense_rank() over (partition by os_kind, use_for order by os_kind, use_for, device_id, device_token))::int/" + mnThread_Group + ")::int, " + mnThread_Max + "), 0, " + mnThread_Max + ", ");
			sbSubSql.append("mod(ceil((dense_rank() over (partition by os_kind, use_for order by os_kind, use_for, device_id, device_token))::int/" + mnThread_Group + ")::int, " + mnThread_Max + "))::int thread_no ");
			sbSubSql.append("from senao_device_registry_view tblA ");
			sbSubSql.append("where tblA.device_token != 'X' AND tblA.update_date > (now() - '1 year'::interval)");
			sbSubSql.append(" and os_kind in (" + oskind + ") ");
		    sbSubSql.append(" and use_for in (" + usefor + ") ");

			if (!strSelectBrand.equals("") && !strSelectBrand.equals("-1"))
				sbSubSql.append("and upper(brand) = '" + strSelectBrand + "' ");
			if (!strSelectModel.equals("") && !strSelectModel.equals("-1"))
				sbSubSql.append("and upper(model) = '" + strSelectModel + "' ");
			if (null != astrIMEI) 
				sbSubSql.append(" and exists (select 1 from senao_pushmessage_imei tblB where tblB.imei = tblA.imei) ");
			
			sbSubSql.append("group by device_id, device_token, use_for, os_kind ");
			
			psqlStmt = conPNC.prepareStatement("insert into senao_pushmessage_pool (device_id, msg_id, device_token, use_for, os_kind, create_date, create_by, register_id, thread_no) "+
			                                   " values (?,?,?,?,?,sysdate,?,?,?)"  );
			rsRegistry = sqlStmtMCS.executeQuery(sbSubSql.toString());
			
			while (rsRegistry.next()) {
				psqlStmt.setString(1, rsRegistry.getString("device_id"));
				psqlStmt.setString(2, rsRegistry.getString("msg_id"));
				psqlStmt.setString(3, rsRegistry.getString("device_token"));
				psqlStmt.setString(4, rsRegistry.getString("use_for"));
				psqlStmt.setString(5, rsRegistry.getString("os_kind"));
				psqlStmt.setString(6, userID);
				psqlStmt.setString(7, rsRegistry.getString("register_id"));
				psqlStmt.setInt(   8, rsRegistry.getInt("thread_no"));
				psqlStmt.addBatch();
				x++;
				if (x%1000 == 0) 
					psqlStmt.executeBatch();
			}
			psqlStmt.executeBatch();
			conPNC.commit();

			//psqlStmt = conMCS.prepareStatement(sbSubSql.toString());
			//psqlStmt.executeUpdate();
			//conMCS.commit();

			sAppInfo = null;
			//設定發送結果內容
			rsPushcounts = sqlStmt.executeQuery("select os_kind, use_for, count(*) as push_counts from senao_pushmessage_pool " +
			                                     "where msg_id like '%" + sMsgId + "' group by use_for,os_kind");
			psqlStmt = conPNC.prepareStatement("update senao_pushmessage set device_count = ? where msg_id like '%" + sMsgId + "' and os_kind = ? and use_for = ?");
			HashMap<String, String> mapPushcounts = new HashMap<String, String>() ;
			while (rsPushcounts.next()) {
				String moskind = rsPushcounts.getString("os_kind");
				String musefor = rsPushcounts.getString("use_for");
				int mpushcounts = rsPushcounts.getInt("push_counts");
				mapPushcounts.put(musefor+":"+moskind, Integer.toString(mpushcounts));
				psqlStmt.setInt   (    1, mpushcounts);
                psqlStmt.setString(    2, moskind);
				psqlStmt.setString(    3, musefor);
				psqlStmt.addBatch();
			}
			psqlStmt.executeBatch();
			
			conPNC.commit();
			sqlStmt.close();
			psqlStmt.close();
			for (String val: straSelectApp) {
				String rPushcounts = mapPushcounts.get(val);
				if (rPushcounts == null)
					rPushcounts = "0";
				strResult = strResult + "發送至 " + val
							+ " 共<font color=\"red\">" +  rPushcounts
							+ "</font>筆<br>";
			}
	    // ************ codes above is by Strong ***************/
	
		} catch (Exception ee) {
			if (mbDebug) {
				ee.printStackTrace();
			}
			out.println("Exception:" + ee.getMessage());
			strResult = "發送設定失敗，請重新操作一次！ ";
%>
<%@ include file="/jsp/include/ReleaseConnMCSPage.jsp"%>
<%@ include file="/jsp/include/ReleasePNCConnPage.jsp"%>
<%
		}
	}
%>
<html>
<head>
<style type="text/css">
.style1 {
	font-size: small;
}

.style2 {
	color: #FF0000;
	font-size: small;
}
</style>
<title>新增推播結果</title>
<script type="text/javascript">
	
</script>

</head>
<body>
	<table>
		<tr>
			<td></td>
			<td><font class="style1"><%=strResult%></font></td>
		</tr>
		<tr>
			<td></td>
			<td><font class="style1"><a href="AppsPushMessage.jsp">繼續推播</a></font>或
				<font class="style1"><a href="AppsQueryMessage.jsp">回訊息查詢</a></font>
			</td>
		</tr>
	</table>

</body>
</html>
<%@ include file="/jsp/include/ReleaseConnMCSPage.jsp"%>