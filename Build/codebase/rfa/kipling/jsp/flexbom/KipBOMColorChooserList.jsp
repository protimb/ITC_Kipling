<%-- Copyright (c) 2002 PTC Inc.   All Rights Reserved --%>

<%-- /////////////////////////////////////////////////////////////////////////////////////--%>
<%-- //////////////////////////////// JSP HEADERS ////////////////////////////////////////--%>
<%-- /////////////////////////////////////////////////////////////////////////////////////--%>
<%@page language="java" session="false"
       import="com.lcs.wc.client.Activities,
                com.lcs.wc.client.web.*,
                com.lcs.wc.util.*,
                com.lcs.wc.db.*,
                com.lcs.wc.color.*,
                com.lcs.wc.document.*,
                com.lcs.wc.flextype.*,
                com.lcs.wc.product.*,
                com.lcs.wc.part.*,
                com.lcs.wc.material.*,
                com.lcs.wc.bom.*,
                wt.locks.LockHelper,
                wt.ownership.*,
                wt.org.*,
				wt.util.*,
                java.text.*,
                java.util.*"
%>
<%-- /////////////////////////////////////////////////////////////////////////////////////--%>
<%-- //////////////////////////////// BEAN INITIALIZATIONS ///////////////////////////////--%>
<%-- /////////////////////////////////////////////////////////////////////////////////////--%>
<jsp:useBean id="type" scope="request" class="com.lcs.wc.flextype.FlexType" />
<jsp:useBean id="tg" scope="request" class="com.lcs.wc.client.web.TableGenerator" />
<jsp:useBean id="fg" scope="request" class="com.lcs.wc.client.web.FormGenerator" />
<jsp:useBean id="flexg" scope="request" class="com.lcs.wc.client.web.FlexTypeGenerator" />
<jsp:useBean id="lcsContext" class="com.lcs.wc.client.ClientContext" scope="request"/>

<% wt.util.WTContext.getContext().setLocale(wt.httpgw.LanguagePreference.getLocale(request.getHeader("Accept-Language")));%>
<%-- /////////////////////////////////////////////////////////////////////////////////////--%>
<%-- ////////////////////////////// INITIALIZATION JSP CODE //////////////////////////////--%>
<%-- /////////////////////////////////////////////////////////////////////////////////////--%>
<%
//setting up which RBs to use
Object[] objA = new Object[0];
String RB_MAIN = "com.lcs.wc.resource.MainRB";
String Flex_MAIN = "com.lcs.wc.resource.FlexBOMRB";
String Color_MAIN = "com.lcs.wc.resource.ColorRB";


String colorLabel = WTMessage.getLocalizedMessage ( Color_MAIN, "color_LBL", objA ) ;
String nOCOLORSTODISPLAYPgHead = WTMessage.getLocalizedMessage ( Flex_MAIN, "nOCOLORSTODISPLAY_PG_HEAD", objA ) ;
String insertColorLabel = WTMessage.getLocalizedMessage ( Flex_MAIN, "insertColor_LBL",objA ) ;
%>
<%!
	public static final String URL_CONTEXT = LCSProperties.get("flexPLM.urlContext.override");
    public static final String getTabClass(String val1, String val2){
        if(val1.equals(val2)){
            return "tabselected";
        }
        return "tab";
    }
%>
<%



    boolean performSearch = FormatHelper.parseBoolean(request.getParameter("performSearch"));
    String colorFlexTypeId = FormatHelper.format(request.getParameter("colorFlexTypeId"));
    SearchResults results = null;
    FlexType flexType = null;
    if(FormatHelper.hasContent(colorFlexTypeId)){
        flexType = FlexTypeCache.getFlexType(colorFlexTypeId);
	} else {
	  flexType = FlexTypeCache.getFlexTypeRoot("Color");
	}
    if(performSearch){
        results = new LCSColorQuery().findColorsByCriteria(request, flexType);
    }

    
%>
<% if(performSearch && results != null && results.getResultsFound() > 0){ %>
<%


    Collection colors = results.getResults();

    TableColumn column;
    Collection columns = new ArrayList();


    column = new TableColumn();
    column.setHeaderLabel(insertColorLabel);
    column.setDisplayed(true);
    column.setLinkMethod("parent.mainFrame.insertColor");
    column.setLinkTableIndex("LCSCOLOR.IDA2A2");
    column.setLinkTableIndex2("LCSCOLOR.COLORNAME");
    column.setLinkMode("ONCLICK");
    column.setConstantDisplay(true);
    column.setConstantValue("<img src='" + URL_CONTEXT + "/images/linker.gif' border='0'" + " onmouseover=\"return overlib('" + FormatHelper.formatJavascriptString(insertColorLabel) + "');\" onmouseout=\"return nd();\">");
    column.setFormatHTML(false);
    columns.add(column);

    column = new TableColumn();
    column.setDisplayed(true);
    column.setHeaderLabel("");
    column.setHeaderAlign("left");
    column.setTableIndex("LCSCOLOR.thumbnail");
    //column.setColumnWidth("30");
    column.setBgColorIndex("LCSCOLOR.ColorHexidecimalValue");
    column.setImage(true);
    column.setImageWidth(75);
    column.setColumnWidth("1%");

// <!--added kipling custom code to disable click of thumbnail for Vendors-- =====>>>>>>>>>>>>>Start-->
	
	 lcsContext.initContext();	 
	 lcsContext.setRequest(request);
	 lcsContext.setCacheSafe(true);
	if(!lcsContext.isVendor){
        column.setLinkMethod("launchImageViewer");
       }
// <!--added kipling custom code to disable click of thumbnail for Vendors-- =====>>>>>>>>>>>>>End-->
 
    column.setLinkTableIndex("LCSCOLOR.thumbnail");
    columns.add(column);

    column = new TableColumn();
    column.setDisplayed(true);
    column.setHeaderLabel(colorLabel);
    column.setHeaderAlign("left");
    column.setLinkMethod("viewObjectNewWindow");
    column.setLinkTableIndex("LCSCOLOR.IDA2A2");
    column.setTableIndex("LCSCOLOR.COLORNAME");
    column.setUseQuickInfo(false);
    column.setLinkMethodPrefix("OR:com.lcs.wc.color.LCSColor:");
    column.setHeaderLink("javascript:resort('LCSColor.idA2A2')");
    columns.add(column);

    columns = flexg.createSearchResultsColumns(flexType, columns);

%>
<%-- /////////////////////////////////////////////////////////////////////////////////////--%>
<%-- ////////////////////////////////////  HTML //////////////////////////////////////////--%>
<%-- /////////////////////////////////////////////////////////////////////////////////////--%>
<script>

</script>
<table width="100%" cellspacing="0" cellpadding="0" class="GROUPBACKGROUND">
    <tr>
        <td>
            <%= tg.drawTable(colors, columns, "") %>
        </td>
    </tr>
</table>
<% } else { // END IF MATERIAL FLEXTYPE ID HAS CONTENT %>
<table width="100%" cellspacing="0" cellpadding="0">
    <tr>
        <td class="HEADING3" align="center">
            <br><br><br><%= nOCOLORSTODISPLAYPgHead %>
        </td>
    </tr>
</table>

<% } %>


