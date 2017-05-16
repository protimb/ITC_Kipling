<%-- Copyright (c) 2002 PTC Inc.   All Rights Reserved --%>

<%-- /////////////////////////////////////////////////////////////////////////////////////--%>
<%-- //////////////////////////////// JSP HEADERS ////////////////////////////////////////--%>
<%-- /////////////////////////////////////////////////////////////////////////////////////--%>
<%@page language="java"
       import="com.lcs.wc.client.Activities,
                com.lcs.wc.client.web.*,
                com.lcs.wc.util.*,
                com.lcs.wc.db.*,
                com.lcs.wc.color.*,
                com.lcs.wc.flextype.*,
                wt.doc.WTDocumentMaster,
                wt.ownership.*,
				wt.util.*,
                wt.org.*,
                java.text.*,
                java.net.*,
                java.util.*"
%>
<%-- /////////////////////////////////////////////////////////////////////////////////////--%>
<%-- //////////////////////////////// BEAN INITIALIZATIONS ///////////////////////////////--%>
<%-- /////////////////////////////////////////////////////////////////////////////////////--%>
<jsp:useBean id="colorModel" scope="request" class="com.lcs.wc.color.LCSColorClientModel" />
<jsp:useBean id="type" scope="request" class="com.lcs.wc.flextype.FlexType" />
<jsp:useBean id="tg" scope="request" class="com.lcs.wc.client.web.TableGenerator" />
<jsp:useBean id="fg" scope="request" class="com.lcs.wc.client.web.FormGenerator" />
<jsp:useBean id="flexg" scope="request" class="com.lcs.wc.client.web.FlexTypeGenerator" />
<jsp:useBean id="lcsContext" class="com.lcs.wc.client.ClientContext" scope="session"/>

<%-- /////////////////////////////////////////////////////////////////////////////////////--%>
<%-- ////////////////////////////// INITIALIZATION JSP CODE //////////////////////////////--%>
<%-- /////////////////////////////////////////////////////////////////////////////////////--%>
<%
    flexg.setModuleName("COLOR");
    
    LCSColor color = colorModel.getBusinessObject();
    String hexValue = color.getColorHexidecimalValue();

    type = color.getFlexType();

    LCSColorLogic logic = new LCSColorLogic();
    String redString = null;
    String greenString = null;
    String blueString = null;

    if(hexValue != null){
       int redInt = logic.toDex(hexValue.substring(0,2));
       int greenInt = logic.toDex(hexValue.substring(2,4));
       int blueInt = logic.toDex(hexValue.substring(4,6));

       redString=Integer.toString(redInt);
       greenString=Integer.toString(greenInt);
       blueString=Integer.toString(blueInt);
    }

    String errorMessage = request.getParameter("errorMessage");
%>
<%

String colorDetailsPageHead = WTMessage.getLocalizedMessage ( RB.COLOR, "colorDetails_PG_Head", RB.objA ) ;
String colorIdentificationGrpTitle = WTMessage.getLocalizedMessage ( RB.COLOR, "colorIdentification_GRP_TLE", RB.objA ) ;
String actionsPageHead = WTMessage.getLocalizedMessage ( RB.COLOR, "action_PG_HEAD", RB.objA ) ;
String nameLabel = WTMessage.getLocalizedMessage ( RB.MAIN, "name_LBL", RB.objA ) ;
String typeLabel = WTMessage.getLocalizedMessage ( RB.MAIN, "type_LBL", RB.objA ) ;
String RGBValuesLabel = WTMessage.getLocalizedMessage ( RB.COLOR, "RGBValues_LBL", RB.objA ) ;
String colorThumbnail = WTMessage.getLocalizedMessage ( RB.COLOR, "colorThumbnail_LBL",RB.objA ) ;
String copyColorLabel = WTMessage.getLocalizedMessage ( RB.COLOR, "copyColor_LBL", RB.objA ) ;
String createAnotherColorBtn = WTMessage.getLocalizedMessage(RB.COLOR,"createAnotherColor_Btn",RB.objA);
%>
<%-- /////////////////////////////////////////////////////////////////////////////////////--%>
<%-- /////////////////////////////////////// JSP METHODS /////////////////////////////////--%>
<%-- /////////////////////////////////////////////////////////////////////////////////////--%>
<%!
	public static final String subURLFolder = LCSProperties.get("flexPLM.windchill.subURLFolderLocation");
	public static final String defaultCharsetEncoding = LCSProperties.get("com.lcs.wc.util.CharsetFilter.Charset","UTF-8");
    public static final String JSPNAME = "ViewColor";
    public static final boolean DEBUG = true;
    public static final String DOCUMENT_REFERENCES = PageManager.getPageURL("DOCUMENT_REFERENCES", null);
    public static final String ACTION_OPTIONS = PageManager.getPageURL("ACTION_OPTIONS", null);
    public static final String WC_META_DATA= PageManager.getPageURL("WC_META_DATA", null);
    public static final String OBJECT_THUMBNAIL_PLUGIN= PageManager.getPageURL("OBJECT_THUMBNAIL_PLUGIN", null);
    public static final String DISCUSSION_FORM_POSTINGS = PageManager.getPageURL("DISCUSSION_FORM_POSTINGS", null);

	String objType = "color"; 

    public static String createSwatch(String number){
    	String swatch = WTMessage.getLocalizedMessage ( RB.COLOR, "swatch_LBL",RB.objA ) ;
    	String notAvailable = WTMessage.getLocalizedMessage ( RB.MAIN, "notAvailable_LBL",RB.objA ) ;
    	String colorSample = WTMessage.getLocalizedMessage ( RB.COLOR, "colorSample_LBL",RB.objA ) ;
     if(number == null || number.length() < 6)
         return FormGenerator.createDisplay(swatch, notAvailable, FormatHelper.STRING_FORMAT, "") ;

      StringBuffer buffer = new StringBuffer();
      buffer.append(FormGenerator.createLabel(colorSample));

      buffer.append("<td>");
      buffer.append("<table border=\"0\" cellspacing=\"0\">");
      buffer.append("   <tr>");
      buffer.append("      <td bgcolor=\"black\" width=\"150\" height=\"150\">");
      buffer.append("         <table width=\"100%\" height=\"100%\" cellspacing=\"0\">");
      buffer.append("            <td bgcolor=\"#" + number + "\">&nbsp;</td>");
      buffer.append("         </table>");
      buffer.append("      </td>");
      buffer.append("   </tr>");
      buffer.append("</table>");
      buffer.append("</td>");

      return buffer.toString();
    }
%>
<%-- /////////////////////////////////////////////////////////////////////////////////////--%>
<%-- /////////////////////////////////////// JAVSCRIPT ///////////////////////////////////--%>
<%-- /////////////////////////////////////////////////////////////////////////////////////--%>
<script>
function createAnotherColor()
{
	//alert('add another color');
	document.MAINFORM.activity.value = '<%= Activities.CREATE_COLOR %>';
    document.MAINFORM.action.value = 'CLASSIFY';
	document.MAINFORM.returnActivity.value = '<%= Activities.VIEW_COLOR %>';
    document.MAINFORM.returnOid.value = '<%= FormatHelper.getObjectId(color) %>';
    submitForm();
}
</script>
<%-- /////////////////////////////////////////////////////////////////////////////////////--%>
<%-- /////////////////////////////////////// HTML ////////////////////////////////////////--%>
<%-- /////////////////////////////////////////////////////////////////////////////////////--%>
<% if(FormatHelper.hasContent(errorMessage)){ %>
<tr>
    <td class="ERROR"><%= java.net.URLDecoder.decode(errorMessage, defaultCharsetEncoding) %>
    </td>
</tr>
<% } %>
<input type="hidden" name="typeId" value="<%= FormatHelper.getObjectId(type) %>">
<input type="hidden" name="colorId" value="<%= FormatHelper.getObjectId(color) %>">
                   <%if(null!=request.getParameter("canCreateAnother")  && FormatHelper.parseBoolean(request.getParameter("canCreateAnother")))
                    		{%>
							<input type="hidden" name="canCreateAnother" value="true">

					<%} %>
<table width="100%">
   <tr>
      <td class="PAGEHEADING">
         <table width="100%" cellspacing="0" cellpadding="0">
            <tr>
               <td class="PAGEHEADINGTITLE">
                  <%= colorDetailsPageHead %>: <%= color.getColorName() %>
               </td>
               	<td class="PAGEHEADINGTEXT" width="1%" align="right" nowrap>
					<jsp:include page="<%=subURLFolder+ DISCUSSION_FORM_POSTINGS %>" flush="true">
                        <jsp:param name="oid" value="<%= FormatHelper.getObjectId(color) %>" />
                    </jsp:include>
                    <%if(null!=request.getParameter("canCreateAnother")  && FormatHelper.parseBoolean(request.getParameter("canCreateAnother")))
                    		{%>
					<a class="button" href="javascript:createAnotherColor()"><%=createAnotherColorBtn%></a>&nbsp; &nbsp; 
					<%} %>
                  &nbsp;<%= actionsPageHead %>:&nbsp;
                  <select onChange="evalList(this)">
                     <option>
                        <jsp:include page="<%=subURLFolder+ ACTION_OPTIONS %>" flush="true">
                            <jsp:param name="type" value="<%= FormatHelper.getObjectId(type) %>" />
                            <jsp:param name="targetOid" value="<%= FormatHelper.getObjectId(color) %>" />
                            <jsp:param name="returnActivity" value="VIEW_COLOR" />
                            <jsp:param name="returnOid" value="<%= FormatHelper.getObjectId(color) %>" />
                            <jsp:param name="updateActivity" value="UPDATE_COLOR" />
                        </jsp:include>
                        <% if (ACLHelper.hasCreateAccess(type)) { %>
                         <option value="copyColor('<%= FormatHelper.getObjectId(color) %>')"><%= copyColorLabel %>
                        <% } %>
                  </select>
                  &nbsp;
               	</td>
               
            </tr>
         </table>
      </td>
   </tr>
   <tr>
      <td valign="top">
         <%= tg.startGroupBorder() %>
         <%= tg.startTable() %>
         <%= tg.startGroupTitle() %><%= colorIdentificationGrpTitle %><%= tg.endTitle() %>
         <%= tg.startGroupContentTable() %>

         <tr>
 <!--added kipling custom code to hide Thumbnail for Vendors-- =====>>>>>>>>>>>>>Start-->
				<%if(!lcsContext.isVendor){%>

		 <td width="180" class="LABEL"><center>
                <jsp:include page="<%=subURLFolder+ OBJECT_THUMBNAIL_PLUGIN %>" flush="true">
                    <jsp:param name="thumbLocation" value="<%= color.getThumbnail() %>"/>
                    <jsp:param name="editable" value="<%= ACLHelper.hasModifyAccess(color) %>"/>
                    <jsp:param name="versionId" value="<%= FormatHelper.getObjectId(color) %>"/>
                    <jsp:param name="activity" value="<%= Activities.UPDATE_COLOR %>"/>
                    <jsp:param name="hexColor" value="<%= hexValue %>"/>
                    <jsp:param name="image" value="thumbnail"/>
                    <jsp:param name="label" value="<%= colorThumbnail %>"/>
                    <jsp:param name="returnActivity" value="VIEW_COLOR"/>
                    <jsp:param name="returnAction" value="INIT"/>
                    <jsp:param name="returnOid" value="<%= FormatHelper.getObjectId(color) %>"/>
                </jsp:include>

				</td>
                <%}%>
 <!--added kipling custom code to hide Thumbnail for Vendors-- =====>>>>>>>>>>>>>End-->

				<td valign="top">
                <table>
                 <col width="15%">
                 <col width="35%">
                 <col width="15%">
                 <col width="35%">
                 <tr>
                <!--%= FormGenerator.createDisplay(nameLabel, color.getColorName(), FormatHelper.STRING_FORMAT) %-->
                <%= FormGenerator.createDisplay(color.getFlexType().getAttribute("name").getAttDisplay(), color.getColorName(), FormatHelper.STRING_FORMAT) %>
                <%= FormGenerator.createDisplay(typeLabel, color.getFlexType().getFullNameDisplay(), FormatHelper.STRING_FORMAT) %>
                </tr>
                <tr>
<!--added kipling custom code to hide RGB values for Vendors-- =====>>>>>>>>>>>>>Start-->
				<%if(!lcsContext.isVendor){%>

				<%= FormGenerator.createDisplay(RGBValuesLabel,  redString + "-" + greenString + "-" + blueString, FormatHelper.STRING_FORMAT) %>

                <%}%>
<!--added kipling custom code to hide RGB values for Vendors-- =====>>>>>>>>>>>>>End-->

				</tr>

                </table>
            </td>
         </tr>
         <%= tg.endContentTable() %>
         <%= tg.endTable() %>
         <%= tg.endBorder() %>
      </td>
   </tr>
   <tr>
      <td>
         <%= flexg.generateDetails(color) %>
      </td>
   </tr>
   <tr>
      <td>
    <jsp:include page="<%=subURLFolder+ DOCUMENT_REFERENCES %>" flush="true">
            <jsp:param name="targetOid" value="<%= FormatHelper.getObjectId(color) %>" />
            <jsp:param name="returnActivity" value="VIEW_COLOR" />
            <jsp:param name="returnOid" value="<%= FormatHelper.getObjectId(color) %>" />
         </jsp:include>
      </td>
   </tr>
   <tr>
      <td>
    <jsp:include page="<%=subURLFolder+ WC_META_DATA %>" flush="true">
            <jsp:param name="targetOid" value="<%= FormatHelper.getObjectId(color) %>" />
         </jsp:include>
      </td>
   </tr>
</table>
