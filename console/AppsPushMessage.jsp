<%@ page language="java" contentType="text/html; charset=utf-8"%>
<%@ page import="java.sql.*,java.lang.String,java.util.Date,java.text.SimpleDateFormat"%>

<%@ include file="/jsp/include/AuthenticationPage.jsp"%>
<%@ include file="/jsp/include/ConnectMCSPoolPage.jsp"%>

<%@include file="AppsPushMessageCommon.jsp"%>

<%
String sOption = "";//2014/6/13 預設推播類型選單
%>
<html>
<head>


<title>新增推播訊息</title>
<style>
    input{
       border:1px solid #577BA8;
    }
</style>
<style type="text/css">
.style1 {
	width: 100px;
}

.style2 {
	width: 90%;
}

#Select1 {
	width: 333px;
}

#Select2 {
	width: 333px;
}

#Select3 {
	width: 333px;
}

#TextArea1 {
	height: 94px;
	width: 333px;
}

#Text1 {
	width: 333px;
}

#Button1 {
	margin-left: 0px;
}

.style8 {
	font-size: large;
	font-weight: bold;
}

.style9 {
	width: 120px;
	font-size: small;
	font-weight: bold;
}

.style11 {
	width: 22px;
}

.style12 {
	width: 80px;
	font-size: small;
}

.style13 {
	font-size: small;
}

.style14 {
	font-size: small;
}

.style15 {
	width: 228px;
}

.style16 {
	width: 80px;
	font-size: small;
}

.style17 {
	color: #FF0000;
	font-size: small;
}
</style>
<script type="text/javascript" src="<%=request.getContextPath()%>/ckeditor/ckeditor.js"></script>
<script language="javascript" type="text/javascript">
    <%
    try
    {	//查出所有品牌，並轉換成javascript的陣列
    	String sBSql = "select upper(brand) as brand from senao_device_registry where brand <> '' and model <> '' group by upper(brand) order by upper(brand)";
		StringBuffer sbBrand = new StringBuffer();
		int iBrand = 0;
    	Statement stmtB =conMCS.createStatement();
    	ResultSet rsB = stmtB.executeQuery(sBSql);
	
    	while(rsB.next())
    	{
    		if(iBrand == 0)
    			sbBrand.append("\"" + rsB.getString("brand") + "\"");
    		else
    			sbBrand.append(",\"" + rsB.getString("brand") + "\"");
    		iBrand++;
    	}
    	rsB.close();
        stmtB.close();
        %>
		var arBrand = new Array(<%=sbBrand.toString()%>);
		
		var arModel = new Array();
    	<%
    	
    	
    	//查出有的品牌及對應的型號，並轉換成javascript的字串陣列
    	String sBMSql = "select upper(brand) as brand, upper(model) as model from senao_device_registry where brand <> '' and model <> '' group by upper(brand), upper(model) order by upper(brand), upper(model)";
    	StringBuffer sbBM = new StringBuffer();
    	int iBM = 0; 
		String sBrand = "";
		Statement stmtBM =conMCS.createStatement();
    	ResultSet rsBM = stmtBM.executeQuery(sBMSql);
        
    	while(rsBM.next())
    	{
    		if(sBrand == "")
    		{
    			sbBM.append(rsBM.getString("model"));
    			sBrand = rsBM.getString("brand");
    		}
    		else if(sBrand.equals(rsBM.getString("brand")))
    		{
    			sbBM.append("," + rsBM.getString("model"));
    			sBrand = rsBM.getString("brand");
    		}
    		else
    		{
		%>
		arModel[<%=iBM%>] = "<%=sbBM.toString()%>";
	    <%
    	    	sbBM.delete(0, sbBM.length());
    	    	sbBM.append(rsBM.getString("model"));
    			sBrand = rsBM.getString("brand");
    			iBM++;
    		}
    		
    	}
    	//迴圈跑完，還有最後一個值要補進去
    	%>
		arModel[<%=iBM%>] = "<%=sbBM.toString()%>";
    	<%
    	rsBM.close();
        stmtBM.close();
    		
    } //end of try
    catch (Exception ee)
    {
    	out.println("Exception:"+ee.getMessage());
    %>
    <%@ include file="/jsp/include/ReleaseConnMCSPage.jsp"%>    
 	<%
    }
    %>
    function PopulateBrandModel(abrand,amodel)
    {
    	var brand = document.getElementById(abrand);
    	var model = document.getElementById(amodel);
    	brand.options.add(new Option("ALL","-1"));
    	model.options.add(new Option("ALL","-1"));
    	for(var i=0;i<arBrand.length;i++)
    	{
    		brand.options.add(new Option(arBrand[i],arBrand[i]));
    	}
    }
    
    function PopulateAgeStartEnd(astart,aend)
    {
    	var agestart = document.getElementById(astart);
    	var ageend = document.getElementById(aend);
    	agestart.options.add(new Option("-","-1"));
    	ageend.options.add(new Option("-","-1"));
    	for(var i=0;i<100;i++)
    	{
    		agestart.options.add(new Option(i,i));
    		ageend.options.add(new Option(99-i,99-i));
    	}
    }
    
    function PopulateCycleDayInterval(aCycleDayInterval)
    {
    	var cycleDayInterval = document.getElementById(aCycleDayInterval);
    	
    	for(var i=1;i<=365;i++)
    		cycleDayInterval.options.add(new Option(i,i));
    }
    
    function ChangeModelbyBrand(vbrand,vmodel)
    {
    	var cbrand = document.getElementById(vbrand);
    	var cmodel = document.getElementById(vmodel);
    	var iB = cbrand.value;
    	var iBIndex = cbrand.selectedIndex-1;
    	cmodel.options.length = 0;
    	if(iB == -1)
    	{
    		cmodel.options.add(new Option("ALL","-1"));
    		return;
    	}
    	var sarModel = arModel[iBIndex].split(",");
    	
    	cmodel.options.add(new Option("ALL","-1"));
    	for(var j=0;j<sarModel.length;j++)
    	{
    		cmodel.options.add(new Option(sarModel[j],sarModel[j]));
    	}
    	
    }
    
    function Populatedropdown(ayearfield, amonthfield, adayfield, ahourfield, aminfield)
    {
    	var today=new Date();
    	var dayfield=document.getElementById(adayfield);
    	var monthfield=document.getElementById(amonthfield);
    	var yearfield=document.getElementById(ayearfield);
    	var hourfield=document.getElementById(ahourfield);
    	var minfield=document.getElementById(aminfield);
    	
    	for (var i=1; i<32; i++)
    		dayfield.options[i-1]=new Option(i, i);
    	dayfield.options[today.getDate()-1]=new Option(today.getDate(), today.getDate(), true, true); //select today's day
    	for (var m=1; m<13; m++)
    		monthfield.options[m-1]=new Option(m, m);
    	monthfield.options[today.getMonth()]=new Option(today.getMonth()+1,today.getMonth()+1, true, true); //select today's month
    	var thisyear=today.getFullYear();
    	for (var y=0; y<20; y++)
    	{
    		yearfield.options[y]=new Option(thisyear, thisyear);
    		thisyear+=1;
    	}
    	yearfield.options[0]=new Option(today.getFullYear(), today.getFullYear(), true, true); //select today's year
    	for (var j=0; j<24; j++)
    		hourfield.options[j]=new Option(j, j);
    	hourfield.options[today.getHours()]=new Option(today.getHours(), today.getHours(), true, true); //select today's hour
    	
    	//分鐘只能設0分或30分
    	minfield.options[0]=new Option(0, 0);
    	minfield.options[1]=new Option(30, 30);
    	if(today.getMinutes()<30)
    	{
    		minfield.options[1] =new Option(30,30,true,true);//如果現在時間小於30分，將分顯示30分
    		hourfield.options[today.getHours()+1]=new Option(today.getHours()+1, today.getHours()+1, true, true);//如果現在時間小於30分，直接設定小時為下一個小時
    	}
    	else
    	{
    		minfield.options[0] =new Option(0,0,true,true);//如果現在時間大於30分，將分顯示0分
    		hourfield.options[today.getHours()+2]=new Option(today.getHours()+2, today.getHours()+2, true, true);//如果現在時間大於30分，直接設定小時為下二個小時
    	}
    	
   }

	function checkData()
	{
		if(!checkAppChecked()) 
		{
		    alert("請選擇APP!");
		    frmPN.SelectApp[0].focus();
		    return;
		}
		
		var contentType = document.getElementById("content_type").value;
		
		if(frmPN.MsgName.value == "" && 'canned' != contentType)
		{
			alert("請輸入訊息名稱!");
			frmPN.MsgName.focus();
		    return;
		}
		
		if(frmPN.Subject.value == "" && 'canned' != contentType)
		{
			alert("請輸入訊息主旨!");
			frmPN.Subject.focus();
		    return;
		}
		
		if('text' == contentType)
		{
			if(frmPN.content_text.value == "")
			{
				alert("請輸入訊息內容!");
				frmPN.content_text.focus();
		    	return;
			}
			document.getElementById("content").value = frmPN.content_text.value;
		}
		else if('html' == contentType)
		{
			var editor_data = CKEDITOR.instances.content_html.getData();
			if(null == editor_data || editor_data == "")
			{
				alert("請輸入HTML訊息內容!");
				frmPN.content_html.focus();
		    	return;
			}
			document.getElementById("content").value = editor_data;
		}
		else if('canned' == contentType)
		{
			var iframe = document.getElementById('content_canned');
			var innerDoc = (iframe.contentDocument) ? iframe.contentDocument : iframe.contentWindow.document;
			var radios = innerDoc.getElementsByName('check_canned');
			document.getElementById("content").value = '';
			for (var i = 0, length = radios.length; i < length; ++i) 
			{
			    if (radios[i].checked) 
			    {
			    	document.getElementById("content").value = radios[i].value;
			        break;
			    }
			}
			if('' == document.getElementById("content").value)
			{
				alert("請選擇一則罐頭訊息!");
				return;	
			}
		}
		if('url' == contentType)
		{
			if(frmPN.content_url.value == "")
			{
				alert("請輸入外部連結網址!");
				frmPN.content_url.focus();
		    	return;
			}
			document.getElementById("content").value = frmPN.content_url.value;
		}
		else if('none' == contentType)
		{
			alert("請輸入訊息內容!");
			return;
		}
		
		if(frmPN.SendingType.value == 0)
		{
			if(frmPN.Hour.value < 7 || frmPN.Hour.value > 21)
			{
				alert("很抱歉！推播訊息可發送的時間為07:00~21:30，請重選預約發送的時間");
				frmPN.Hour.focus();
				return;
			}
			//檢查發送時不可小於現在時間+1個小時	
			var st= new Date(frmPN.Year.value,frmPN.Month.value-1,frmPN.Day.value,frmPN.Hour.value,frmPN.Min.value);
			var now = new Date();
			now.setHours((new Date().getHours())+1);
			if(st<now)
			{
				alert("預約發送時間需早於可發送時間 !!");
				return;
			}
		}
		frmPN.submit();
	}
	
	function checkAppChecked()
	{
		for (var i = 0; i < frmPN.SelectApp.length; i++)
		{
			if (frmPN.SelectApp[i].checked)
		         return true;
		}
		return false;
	}
	
	function Model_Msg_Show(Flag) 
	{
		document.getElementById("content_type").value = Flag;
		
		if (Flag == 'text') 
		{
			if(typeof CKEDITOR.instances['content_html'] != 'undefined') 
			{
			    CKEDITOR.instances['content_html'].updateElement();
			    CKEDITOR.instances['content_html'].destroy();
			}
			document.getElementById("content_canned").style.display = "none";
			document.getElementById("content_html").style.display = "none";
			document.getElementById("content_url").style.display = "none";
			document.getElementById("content_text").style.display = "";
			document.getElementById("trMsgName").style.display = "";
			document.getElementById("trSubject").style.display = "";
			document.getElementById("content_text").focus();
		}
		else if (Flag == 'html')
		{
			document.getElementById("content_canned").style.display = "none";
			document.getElementById("content_text").style.display = "none";
			document.getElementById("content_url").style.display = "none";
			document.getElementById("content_html").style.display = "";
			document.getElementById("trMsgName").style.display = "";
			document.getElementById("trSubject").style.display = "";
			CKEDITOR.replace('content_html',{
  				skin : "kama",
  				uiColor : "#577BA8",
  				filebrowserImageBrowseUrl : "<%=request.getContextPath()%>/ckeditor/uploader/browse.jsp?path=<%=PATH_IMAGE%>",
  				filebrowserImageUploadUrl : "<%=request.getContextPath()%>/ckeditor/uploader/upload.jsp?path=<%=PATH_IMAGE%>"	
 				});
			document.getElementById("content_html").focus();
		}
		else if (Flag == 'canned')
		{
			if(typeof CKEDITOR.instances['content_html'] != 'undefined') 
			{
			    CKEDITOR.instances['content_html'].updateElement();
			    CKEDITOR.instances['content_html'].destroy();
			}
			document.getElementById("content_canned").src = "./AppsPushMessageCannedList.jsp";
			document.getElementById("content_text").style.display = "none";
			document.getElementById("content_html").style.display = "none";
			document.getElementById("content_url").style.display = "none";
			document.getElementById("trMsgName").style.display = "none";
			document.getElementById("trSubject").style.display = "none";
			document.getElementById("content_canned").style.display = "";
		}
		else if (Flag == 'url') //2014.09.09 Edited by Romeo
		{
			if(typeof CKEDITOR.instances['content_html'] != 'undefined') 
			{
			    CKEDITOR.instances['content_html'].updateElement();
			    CKEDITOR.instances['content_html'].destroy();
			}
			document.getElementById("content_canned").style.display = "none";
			document.getElementById("content_html").style.display = "none";
			document.getElementById("content_text").style.display = "none";
			document.getElementById("content_url").style.display = "";
			document.getElementById("trMsgName").style.display = "";
			document.getElementById("trSubject").style.display = "";
			document.getElementById("content_url").focus();
		}
	}
	
	function SendingTypeChange()
	{
		//alert("!!");
		//var sendType = frmPN.SendingType.value;
		//alert(sendType);
		if(frmPN.SendingType.value == 2)
			document.getElementById("CrmTable").style.display = "";
		else
			document.getElementById("CrmTable").style.display = "none";
	}
	
</script>

</head>
<body>
	<form name="frmPN" method="post" action="AppsGetPushMessage.jsp" enctype="multipart/form-data">
		<table>
			<tr>
				<td><font class="style8"><A
						HREF='/ec/ECBackStageMainMenu.jsp'>回首頁</A></font></td>
				<td><font class="style8"><a href="AppsQueryMessage.jsp">回訊息查詢</a></font></td>
				<td></td>
			</tr>
		</table>
		<table border="1" style="width: 100%; height: 70px;">
			<tr>
				<td class="style9" align="right">推播條件選擇</td>
				<td class="style2">
					<table style="width: 100%;">
						<tr>
							<td class="style12" align="right">選擇APP：</td>
							<td>
								<table>


<%
	String strHtmlContent = "";
	
try
{
	String sSql = null;
	String sSubSql = "and lk.code_subvalue ='USER' ";

	//如果是Admin權限的使用者，可以看到所有的APP推播選項
	if (userRoles!=null && (userRoles.indexOf("Admin")>=0))
	{
		sSubSql = "";
		//2015/03/04 推播類型的選單
		sOption = sOption + "<option value=\"NOTICE\">通知(NOTICE)</option>";
		sOption = sOption + "<option value=\"ORDER\">訂單相關(ORDER)</option>";
		sOption = sOption + "<option value=\"VIP\">VIP優惠(VIP)</option>";
		sOption = sOption + "<option value=\"HELLO\">歡迎使用(HELLO)</option>";
		sOption = sOption + "<option value=\"UPDATE\">系統更新(UPDATE)</option>";
		sOption = sOption + "<option value=\"PING\">系統測試(PING)</option>";
		sOption = sOption + "<option value=\"SYSTEM\">系統訊息(SYSTEM)</option>";
		sOption = sOption + "<option value=\"ADMAG\">資訊購物誌(ADMAG)</option>";
	}
	
	//2014/6/13如果是PNUser_MCS，僅能看到行動客服MCS的推播選項	
	if (userRoles!=null && (userRoles.indexOf("PNUser_MCS")>=0))
	{
		sSubSql = sSubSql+" and tp.USE_FOR='MCS'";
		//2014/03/04 推播類型的選單
		sOption = sOption + "<option value=\"SYSTEM\">系統訊息(SYSTEM)</option>";
	}
	
	//2014/6/13如果是PNUser_SENAOAPP，僅能看到行動客服SENAOAPP的推播選項		
	if (userRoles!=null && (userRoles.indexOf("PNUser_SENAOAPP")>=0))
	{
		sSubSql = sSubSql+" and tp.USE_FOR='SENAOAPP'";
		//2014/6/13 推播類型的選單
		sOption = sOption + "<option value=\"NOTICE\">通知(NOTICE)</option>";
		//2014/10/24 新增VIP推播類型的選單 edit by Romeo
		sOption = sOption + "<option value=\"VIP\">VIP優惠(VIP)</option>";
		//2015/03/04新增ADMAG資訊購物誌 edit by Romeo
		sOption = sOption + "<option value=\"ADMAG\">資訊購物誌(ADMAG)</option>";
	}
	//如果locale是886就是TW，非886就CN
	String sSub2Sql = "";
	//out.println(locale);
	if(locale!=null && (locale.indexOf("886")>=0))
		sSub2Sql = "and lk.code_submeaning ='TW'";
	else
		sSub2Sql = "and lk.code_submeaning ='CN'";
	
	sSql = "SELECT tp.use_for,tp.transport_name,tp.os_kind,lk.code_subvalue  "+ 
		   "FROM senao_pushmessage_transport tp,senao_mcs_lookups lk " +
	       "where tp.USE_FOR=lk.CODE_VALUE and tp.IS_ACTIVE='Y' " +
		   "and lk.TYPE_CODE='USE_FOR' and lk.VALID='Y' " +
		    sSubSql + sSub2Sql +
		   "order by tp.transport_name, tp.os_kind;";
	Statement statement=conMCS.createStatement();
	ResultSet rs=statement.executeQuery(sSql);
	//out.println(sSql);
	while(rs.next())
	{
		String useFor = rs.getString("use_for");	
		String transportName =  rs.getString("transport_name");
		String osKind =rs.getString("os_kind");
		if(rs.isFirst()) out.println("<tr>");
		if((rs.getRow()-1)%2==0 && !rs.isLast() && !rs.isFirst()) out.println("</tr><tr>");
		
	%>
									<td><input TYPE="checkbox" name="SelectApp"
										VALUE="<%=useFor+":"+osKind%>"><font class="style13"><%=transportName+"_"+osKind%></font></td>

									<%	
		if(rs.isLast()) out.println("</tr>");
	}
	
	rs.close();
	statement.close();

	
} //end of try
catch (Exception ee)
{
	out.println("Exception:"+ee.getMessage());
%>
									<%@ include file="/jsp/include/ReleaseConnMCSPage.jsp"%>
									<%	
}
%>
								</table>
							</td>
						</tr>
						<tr>
							<td class="style12" align="right">手機品牌：</td>
							<td><select id="SelectBrand" name="SelectBrand"
								onChange="ChangeModelbyBrand('SelectBrand','SelectModel');"></select>
								<font class="style12">手機型號：</font> <select id="SelectModel"
								name="SelectModel"></select></td>
						</tr>
						<tr>
							<td class="style12" align="right">訊息類別：</td>
							<td>
								<select name="SelectMsgType"><%=sOption%>
								</select>
							</td>
						</tr>
						<tr style="display:none;">
							<td class="style12" align="right">年齡：</td>
							<td>
								<select id="SelectAgeStart" name="SelectAgeStart"></select>
								<font class="style12">~</font>
								<select id="SelectAgeEnd" name="SelectAgeEnd" ></select>
								<font class="style12">歲</font>
							</td>
						</tr>
					<tr>
							<td class="style12" align="right">上傳名單：</td>
							<td><input type="file" name="UploadFile" size="20"
								maxlength="20" onChange=
								"document.getElementById('SelectBrand').disabled = 'disabled';
								 document.getElementById('SelectBrand').value='-1';
								 document.getElementById('SelectModel').disabled = 'disabled';
								 document.getElementById('SelectModel').value='-1';
								">
					</tr>
				</table>
				</td>
			</tr>
			<tr>
				<td class="style1">&nbsp;</td>
				<td class="style2">&nbsp;</td>
			</tr>
			<tr>
				<td class="style9" align="right">推播訊息內容</td>
				<td >
					<table style="width: 100%;">
						<tr id="trMsgName">
							<td class="style16" align="right">訊息名稱：</td>
							<td><input name="MsgName" type="text" maxlength="20" /> <font
								class="style17">&nbsp;*訊息名稱，請字數控制於20字內</font></td>
						</tr>
						<tr id="trSubject">
							<td class="style16" align="right">訊息主旨：</td>
							<td><textarea name="Subject" maxlength="30" cols="20"
									rows="2"></textarea> <font class="style17">&nbsp;*此欄位為推播訊息的呈現資訊，請字數控制於30字內</font>
							</td>
						</tr>
						<tr>
							<td class="style16" align="right">
							訊息內容：
							</td>
							<td>
							<input name="btn_msg_text"   type="button" id="btn_msg_text"   value="文字內容"	onClick="Model_Msg_Show('text')" />  
							<input name="btn_msg_html"   type="button" id="btn_msg_html"   value="Html內容"	onClick="Model_Msg_Show('html')" />
							<input name="btn_msg_canned" type="button" id="btn_msg_canned" value="罐頭訊息"	onClick="Model_Msg_Show('canned')" />
							<input name="btn_msg_url"   type="button" id="btn_msg_url"   value="外部連結"	onClick="Model_Msg_Show('url')" />  
							</td>
						</tr>
							<tr>
							<td colspan="2" style="text-align: left;">
							<input name="content_type" id="content_type" type="hidden" value="none"/>
							<input name="content" id="content" type="hidden" />
								&nbsp;&nbsp;&nbsp;
								<!-- 文字訊息 -->
								<textarea name="content_text" id="content_text" cols="20" rows="3" style="display:none;"></textarea>
								<!-- Html訊息 -->	
								<textarea id="content_html" name="content_html" style="display:none;"><%=strHtmlContent%></textarea>
								<!-- 罐頭訊息 -->
								<iframe name="content_canned" id="content_canned" src='#'  style="width:90%; display: none" align="center"></iframe>
								<!-- 外部連結 -->
								<textarea name="content_url" id="content_url" cols="50" rows="3" style="display:none;"></textarea>
							</td>
							</tr>
					</table>
				</td>
			</tr>
			<tr>
				<td class="style1">&nbsp;</td>
				<td class="style2">&nbsp;</td>
			</tr>
			<tr>
				<td class="style9" align="right">訊息發送型式</td>
				<td class="style2">
					<table style="width: 100%;">
						<tr>
							<td class="style11"><input type="radio" checked="checked" onclick="SendingTypeChange();"
								name="SendingType" value="1" /></td>
							<td class="style14">立即發送</td>
							<td>&nbsp;</td>
						</tr>
						<tr>
							<td class="style11"><input type="radio" name="SendingType"
								value="0" onclick="SendingTypeChange();"/></td>
							<td class="style14">預約發送</td>
							<td align="left"><select id="Year" name="Year"
								class="style14">
							</select><span class="style14">年 <select id="Month" name="Month">
								</select>月 <select id="Day" name="Day">
								</select>日 <select id="Hour" name="Hour">
								</select>時 <select id="Min" name="Min">
								</select>分
							</span>
								<font class="style17">&nbsp;*可預約發送時間需大於目前時間後一小時 </font>
							</td>
						<!-- 	<td class="style17">可預約發送時間需大於目前時間後一小時</td> -->
						</tr>
						<tr style="display:none;">
							<td class="style11"><input type="radio" name="SendingType" value="2" onclick="SendingTypeChange();"/></td>
							<td class="style14">定時發送</td>
							<td>
								<table id="CrmTable" style="display:none;">
									<tr>
										<td class="style12" align="right">定時型態：</td>
										<td>
											<select name="CycleType">
												<option value="REPAIR_A">維修後</option>
												<option value="REPAIR_B">維修前</option>
												<option value="BIRTHDAY_B">生日前</option>
												<option value="BIRTHDAY_A">生日後</option>
											</select>
											<select name="CycleDayInterval" id="CycleDayInterval"></select>
											<span class="style14">天</span>	
										</td>
									</tr>
								</table>
							</td>
						</tr>
							<script type="text/javascript">
									window.onload=function()
									{
										PopulateBrandModel("SelectBrand","SelectModel");
										Populatedropdown("Year", "Month", "Day", "Hour", "Min");
										PopulateAgeStartEnd("SelectAgeStart","SelectAgeEnd");
										PopulateCycleDayInterval("CycleDayInterval");
									}
							</script>
						<tr>
						</tr>
						<tr>
							<td></td>
							<td></td>
							
						</tr>
					</table>
				</td>
			</tr>
			<tr style="width: 100%;">
				<td class="style2" COLSPAN=2 align="center">
					<table style="width: 100%;">
						<tr align="center" style="width: 100%;">
							<td align="right" >
							<input type="button" value="發送" onClick="checkData();" style="width: 120;height: 40"/></td>
							<td align="left">
							&nbsp;<input type="reset" value="取消" onClick="document.getElementById('SelectBrand').disabled = '';" style="width: 120;height: 40"/></td>
						</tr>
					</table>
				</td>
			</tr>

		</table>
	</form>
</body>
</html>
<%@ include file="/jsp/include/ReleaseConnMCSPage.jsp"%>