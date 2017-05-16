<%-- Copyright (c) 2002 PTC Inc.   All Rights Reserved --%>

<%-- /////////////////////////////////////////////////////////////////////////////////////--%>
<%-- //////////////////////////////// JSP HEADERS ////////////////////////////////////////--%>
<%-- /////////////////////////////////////////////////////////////////////////////////////--%>
<%@page language="java" session="false"
       import="com.lcs.wc.client.Activities,
                com.lcs.wc.client.web.*,
                com.lcs.wc.util.*,
                com.lcs.wc.db.*,
                com.lcs.wc.document.*,
                com.lcs.wc.flexbom.*,                
                com.lcs.wc.flextype.*,
                com.lcs.wc.part.*,
                com.lcs.wc.product.*,
                com.lcs.wc.season.*,
                com.lcs.wc.foundation.*,
                com.lcs.wc.part.*,
                com.lcs.wc.color.*,
                com.lcs.wc.bom.*,
                wt.locks.LockHelper,
                wt.ownership.*,
				wt.util.*,
                wt.org.*,
                wt.fc.*,
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
String typeLabel = WTMessage.getLocalizedMessage ( RB_MAIN, "type_LBL", objA ) ;
String paletteLabel = WTMessage.getLocalizedMessage ( Color_MAIN, "palette_LBL", objA ) ;
String loadPaletteLabel = WTMessage.getLocalizedMessage ( RB.FLEXBOM, "loadPalette_LBL", objA ) ;
String searchLabel = WTMessage.getLocalizedMessage ( RB_MAIN, "search_Btn", objA ) ;
String listLabel = WTMessage.getLocalizedMessage ( Flex_MAIN, "list_LBL", objA ) ;
String recentLabel = WTMessage.getLocalizedMessage ( Flex_MAIN, "recent_LBL", objA ) ;
String colorTypeLabel = WTMessage.getLocalizedMessage ( Flex_MAIN, "colorType_LBL", objA ) ;
String insertColorLabel = WTMessage.getLocalizedMessage ( Flex_MAIN, "insertColor_LBL",objA ) ;
String quickSpecLabel = WTMessage.getLocalizedMessage ( RB.PRODUCT, "quickSpecification_LBL", RB.objA );
String favoritesLabel = WTMessage.getLocalizedMessage ( RB.MAIN, "favorites_LBL", RB.objA ) ;

String parentLabel = WTMessage.getLocalizedMessage ( Color_MAIN, "parentPalette_LBL", objA ) ;
String childLabel =  WTMessage.getLocalizedMessage ( Color_MAIN, "childPalette_LBL", objA ) ;
%>
<%!
	public static final String subURLFolder = LCSProperties.get("flexPLM.windchill.subURLFolderLocation");
	public static final String URL_CONTEXT = LCSProperties.get("flexPLM.urlContext.override");
	public static final String WT_IMAGE_LOCATION = LCSProperties.get("flexPLM.windchill.ImageLocation");
    static final String BOM_COLOR_CHOOSER_LIST = PageManager.getPageURL("BOM_COLOR_CHOOSER_LIST", null);
    static final String BOM_PALETTE_SELECTION = PageManager.getPageURL("BOM_PALETTE_SELECTION", null);
    public static final String getTabClass(String val1, String val2){
        if(val1.equals(val2)){
            return "tabselected";
        }
        return "tab";
    }
%>
<%
    String seasonId = request.getParameter("seasonId");
    LCSSeason season = null;
    LCSPalette palette = null;



    ///////////////////////////////////////////////////////////
    // PALETTE SELECTION: SHOULD BE DONE WITH A PLUGIN
    ///////////////////////////////////////////////////////////
    if(FormatHelper.hasContent(seasonId)){
        season = (LCSSeason) LCSQuery.findObjectById(seasonId);
        request.setAttribute("contextSeason", season);

    	if(FormatHelper.hasContent(request.getParameter("paletteOid")))
    	{
    	   String paletteID = request.getParameter("paletteOid");
    	   LCSPaletteQuery query = new LCSPaletteQuery();
    	   palette =  (LCSPalette) query.findObjectById(paletteID);
    	}else{
	        %>
	        <jsp:include page="<%=subURLFolder+ BOM_PALETTE_SELECTION %>" flush="true">
	            <jsp:param name="none" value="" />
	        </jsp:include>
	        <%
	        palette = (LCSPalette) request.getAttribute("contextPalette");
    	}
    	 if(palette == null){
            palette = season.getPalette();
            
        } else {
            System.out.println("Using Palette from Context");
        }
    	 
 		try{
		    if (!ACLHelper.hasViewAccess(palette))
		        palette = null;
		}
		catch (Exception e){
		    palette = null;
		}
    	 
    }
    
    ///////////////////////////////////////////////////////////



    /////////////////////////////////////////////////
    // SET UP FOR THE SEARCH CRITERIA DIV
    /////////////////////////////////////////////////
    FlexType flexType = FlexTypeCache.getFlexTypeFromPath("Color");
    Iterator allColorTypes = flexType.getAllViewableChildren().iterator();
    FlexType childType;
    Hashtable childTypeMap = new Hashtable();
    while(allColorTypes.hasNext()){
        childType = (FlexType) allColorTypes.next();
        childTypeMap.put(FormatHelper.getObjectId(childType), childType.getFullNameDisplay());
    }

    FlexBOMPart bomPart = (FlexBOMPart) request.getAttribute("contextBOMPart");
    if(bomPart == null){
        bomPart = (FlexBOMPart) LCSQuery.findObjectById(request.getParameter("oid"));    	
    }
    String errorMessage = request.getParameter("errorMessage");
    FlexType colorRootType = FlexTypeCache.getFlexTypeFromPath("Color");
    Collection paletteData = new Vector();
    TableColumn column;
    Collection columns = new ArrayList();
    Hashtable columnMap = new Hashtable();
    Vector columnList = new Vector();

    tg.setClientSort(true);
    
    if(palette != null){
        /////////////////////////////////////////////////
        // SET UP FOR THE PALETTE DIV
        /////////////////////////////////////////////////
        FlexType paletteType = FlexTypeCache.getFlexTypeFromPath("Palette");
        Collection colors = new LCSPaletteQuery().findColorsForPalette(palette, RequestHelper.hashRequest(request));
        boolean hasAccess = ACLHelper.hasModifyAccess(palette);


        column = new TableColumn();
        column.setHeaderLabel("");
        column.setDisplayed(true);
        column.setLinkMethod("parent.mainFrame.insertColor");
        column.setLinkTableIndex("LCSCOLOR.IDA2A2");
        column.setLinkTableIndex2(colorRootType.getAttribute("name").getSearchResultIndex());
        column.setLinkMode("ONCLICK");
        //column.setLinkMethodPrefix("OR:com.lcs.wc.measurements.LCSPointsOfMeasure:");
        column.setConstantDisplay(true);
        column.setConstantValue("<img title='" + insertColorLabel + "' src='" + URL_CONTEXT + "/images/linker.gif' border='0'"+ " onmouseover=\"return overlib('" + FormatHelper.formatJavascriptString(insertColorLabel) + "');\" onmouseout=\"return nd();\">");
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
        columnMap.put("COLOR.thumbnail", column);

        column = new TableColumn();
        column.setDisplayed(true);
        column.setHeaderLabel(colorLabel);
        column.setHeaderAlign("left");
        column.setLinkMethod("viewObjectNewWindow");
        column.setLinkTableIndex("LCSCOLOR.IDA2A2");
        column.setTableIndex("LCSCOLOR.COLORNAME");
        column.setLinkMethodPrefix("OR:com.lcs.wc.color.LCSColor:");
        column.setHeaderLink("javascript:resort('LCSColor.colorName')");
        column.setWrapping(false);
        columnMap.put("COLOR.name", column);


        column = new FlexTypeDescriptorTableColumn();
        column.setDisplayed(true);
        column.setHeaderLabel(typeLabel);
        column.setHeaderAlign("left");
        column.setTableIndex("LCSCOLOR.BRANCHIDA2TYPEDEFINITIONREFE");
        column.setHeaderLink("javascript:resort('FlexType.typeName')");
        columnMap.put("COLOR.flexType", column);


        flexg.setScope(PaletteColorFlexTypeScopeDefinition.PALETTE_COLOR_SCOPE);
        flexg.setLevel(null);
        flexg.createTableColumns(paletteType, columnMap, paletteType.getAllAttributes(PaletteColorFlexTypeScopeDefinition.PALETTE_COLOR_SCOPE, null, false), false, "PALETTECOLORLINK.");


        flexg.setScope(null);
        flexg.setLevel(null);
        flexg.createTableColumns(colorRootType, columnMap, colorRootType.getAllAttributes(), false, "COLOR.");

        columnList.add("actions");
        columnList.add("COLOR.thumbnail");
        columnList.add("PALETTECOLORLINK.paletteColorName");
        columnList.add("COLOR.name");
        //columnList.add("COLOR.flexType");
        columnList.add("COLOR.pantoneRef");
        paletteData = colors;

        ////////////////////////////////////////////////////////////////
        // SET TABLE ROW ID INDEX: USED TO UNIQUELY IDENTIFY
        // A ROW IN THE TABLE.
        ////////////////////////////////////////////////////////////////
        tg.setRowIdIndex("LCSPALETTETOCOLORLINK.IDA2A2");


//        Collection groupByColumns = new ArrayList();
//        groupByColumns.add(columnMap.get("COLOR.flexType"));
//        tg.setGroupByColumns(groupByColumns);
//        tg.setSpaceBetweenGroups(false);

        TableColumn potentialColumn;
        Iterator it = columnList.iterator();
        String key = "";
        while(it.hasNext()){
            key = (String)it.next();
            potentialColumn = (com.lcs.wc.client.web.TableColumn) columnMap.get(key);
            if(potentialColumn != null){
                columns.add(potentialColumn);
                columnMap.remove(key);
                if(key.indexOf(".") > 0){
                    key = key.substring(key.indexOf(".") + 1, key.length());
                }
                //attList.add(key);
            }
        }
    } // END PALETTE != null


    String colorChooserTab = request.getParameter("colorChooserTab");
    if(!FormatHelper.hasContent(colorChooserTab)){
        colorChooserTab = "searchTab";
    }

    String selectedTypeId = request.getParameter("colorFlexTypeId");
    FlexType selectedType = colorRootType;
    if(FormatHelper.hasContent(selectedTypeId)){
        selectedType = FlexTypeCache.getFlexType(selectedTypeId);
    }

    // QUICK SPEC HANDLING
    LCSDocument quickSpec = null;
    
    if(bomPart.getOwnerMaster() instanceof LCSPartMaster){
        WTObject owner = (WTObject)VersionHelper.getVersion((BOMOwner)bomPart.getOwnerMaster(), "A");
        if(owner instanceof LCSProduct){
            quickSpec = new LCSDocumentQuery().getProductQuickSpec((LCSProduct)owner);
            
        }    	
    }
    
    
%>


<%-- /////////////////////////////////////////////////////////////////////////////////////--%>
<%-- ////////////////////////////////////  HTML //////////////////////////////////////////--%>
<%-- /////////////////////////////////////////////////////////////////////////////////////--%>
<script>
    function showTab(tabId){

        <% if(palette != null){ %>
        hideDiv("paletteTabDiv");
        <% } %>
        hideDiv("searchTabDiv");
        hideDiv("listTabDiv");
        <% if(quickSpec != null){ %>
        hideDiv("quickSpecTabDiv");
        <% } %>
        hideDiv("favoritesTabDiv");

        showDiv(tabId + "Div");

        <% if(palette != null){ %>
        document.getElementById("paletteTab").className = 'tab';
        <% } %>
        document.getElementById("searchTab").className = 'tab';
        document.getElementById("listTab").className = 'tab';
        <% if(quickSpec != null){ %>
        document.getElementById("quickSpecTab").className = 'tab';
        <% } %>
        document.getElementById("favoritesTab").className = 'tab';

        document.getElementById(tabId).className = 'tabselected';
    }

    function search(){

        document.MAINFORM.activity.value='CHOOSE_BOM_COLOR';
        document.MAINFORM.action.value='INIT';
        document.MAINFORM.skipRanges.value='true';
        document.MAINFORM.colorChooserTab.value='listTab';
        document.MAINFORM.performSearch.value='true';
        submitForm();
    }

    function changeType(){
        document.MAINFORM.activity.value='CHOOSE_BOM_COLOR';
        document.MAINFORM.action.value='INIT';
        document.MAINFORM.skipRanges.value='true';
        document.MAINFORM.colorChooserTab.value='searchTab';
        submitForm();
    }

    function changePalette()
    {
 		if(document.MAINFORM.paletteOid.value != ' ') 
 		{
 			submitForm();
 		}
    }

</script>
<input type="hidden" name="colorChooserTab" value="<%= colorChooserTab %>">
<input type="hidden" name="skipRanges" value="true">
<input type="hidden" name="performSearch" value="false">
<table width="100%" cellspacing="1" cellpadding="1" border="0">
<tr>
    <td>
        <table width="100%">
            <td width="99%">
                <ul id="tabnav">
                <% if(palette != null){ %>
                <li id="paletteTab" class="tab"><a href="javascript:showTab('paletteTab')"><%= paletteLabel %></a></li>
                <% } %>
                <li id="searchTab" class="tab"><a href="javascript:showTab('searchTab')"><%= searchLabel %></a></li>
                <li id="listTab" class="tab"><a href="javascript:showTab('listTab')"><%= listLabel %></a></li>
                 <% if(quickSpec != null){ %>
                 <li id="quickSpecTab" class="tab"><a href="javascript:showTab('quickSpecTab')"><%= quickSpecLabel %></a></li>                 
                 <% } %>
                 <li id="favoritesTab" class="tab"><a href="javascript:showTab('favoritesTab')"><%= favoritesLabel %></a></li>                 
                </ul>

            </td>
            <td align="right" width="1%">
            <img onClick="parent.mainFrame.toggleColorFrame()" onMouseOut="swapImage(this, '<%=WT_IMAGE_LOCATION%>/closebutton.png')" onMouseOver="swapImage(this, '<%=URL_CONTEXT%>/images/close_button_white_on_bl.gif')" src="<%=WT_IMAGE_LOCATION%>/closebutton.png">
            </td>
        </table>
    </td>
</tr>
<tr>
    <td>
        <table width="100%" cellspacing="0" cellpadding="0">
            <tr>
                <td>
                    <% if(palette != null){ %>
                    <div id="paletteTabDiv">
                            <input type="hidden" name="loadPalette" value="<%= request.getParameter("loadPalette") %>">
                            <input type="hidden" name="loadPaletteRequest" value="">

                            <% 
                                boolean loadPalette = FormatHelper.parseBoolean(request.getParameter("loadPalette"));                                
                                if(loadPalette){ 
                            		/////////////////////////////////////////////////
                                    // SET UP FOR THE PALETTE DROPDOWN LIST
                                    /////////////////////////////////////////////////	
                            		LCSPalette parent = null;
                            		String seasonPalette = null == season || null == season.getPalette() ? null:season.getPalette().getIdentity();
                            		String currentPalette = palette.getIdentity();
                            		String parentName = null;
                            		
                            	    parent = palette.getParentPalette(); 
                            	    if (parent == null){
                            	    	parent = palette;
                            	    	parentName = parent.getPaletteName();
                            	    }else{
                                	    if (!ACLHelper.hasViewAccess(parent)){
                                	    	parent = palette;
                                	    	parentName = parent.getPaletteName();
                                	    }
                                	    else{
                                	    	parentName = parent.getPaletteName() + " " + parentLabel;
                                	    }
                            	    }

                            	    Vector order = new Vector(); 
                            	    Map subPaletteMap = new HashMap();
                            		Collection subs = new LCSPaletteQuery().findSubPalettes(parent, true);
                            		subPaletteMap.put(FormatHelper.getObjectId(parent), parentName);
                            		order.add(FormatHelper.getObjectId(parent));
                            		subPaletteMap.put(" ", "-----------------");
                            		
                            		Iterator subPalletteItr = null;
                            		LCSPalette sub = null;
                            		if (parent != palette){
                            			subPalletteItr = subs.iterator();
                            	
                            			order.add(" "); 
                            			while (subPalletteItr.hasNext()) 
                            			{                            				
                            				sub = (LCSPalette)subPalletteItr.next();
                                    			subPaletteMap.put(FormatHelper.getObjectId(sub), sub.getPaletteName()); 
                                    			order.add(FormatHelper.getObjectId(sub));
                            			} 
                            		}
                                   //sub palettes		
                            	   order.add(" ");
                            	   Collection subSubs = new LCSPaletteQuery().findSubPalettes(palette, true);
                            		subPalletteItr = subSubs.iterator();
                            		while (subPalletteItr.hasNext()) 
                            		{
                            			sub = (LCSPalette)subPalletteItr.next();
                                    		subPaletteMap.put(FormatHelper.getObjectId(sub), sub.getPaletteName() + " " + childLabel); 
                                			order.add(FormatHelper.getObjectId(sub));
                            		}
 
                                %>
                                <table width="100%">
								<tr>
                                <td>
									<%= fg.createDropDownListWidget( paletteLabel, subPaletteMap, "paletteOid", FormatHelper.getObjectId(palette), "javascript:changePalette()", false, order) %>
								</td>
								</tr>
								<tr>
                                <td>
                                    <table width="100%" cellspacing="0" cellpadding="0">
                                    <% if(paletteData.size() > 0){ %>
                                        <tr>
                                            <td>
                                            	<%= tg.drawTable(paletteData, columns, null) %>
                                            </td>
                                        </tr>
                                    <% } %>
                                    </table>
                                </td>
                            	</tr>
                            	 </table>

                            <% } else { %>

                            <script>
                                function showPalette(){

                                    document.MAINFORM.loadPalette.value=true;
                                    document.MAINFORM.loadPaletteRequest.value=true;
                                    document.MAINFORM.colorChooserTab.value='paletteTab';
                                    submitForm();
                                }
                            </script>

                            <table><td class="button"><a class="button" href="javascript:showPalette()"><%= loadPaletteLabel %></a></td></table>


                            <% } %>
                        
                    </div>
                    <% } %>
                    <div id="searchTabDiv">
                     <%= tg.startGroupBorder() %>
                     <%= tg.startTable() %>
                     <%= tg.startGroupContentTable() %>
                        <tr>
                            <td class="button"  align="left"  colspan="2">
                                <a class="button" href="javascript:search()"><%= searchLabel %></a><br><br>
                            </td>
                        </tr>
                        <tr>

                            <%= fg.createDropDownListWidget(colorTypeLabel, childTypeMap, "colorFlexTypeId", request.getParameter("colorFlexTypeId"), "changeType();", false, true) %>

                        </tr>
                        <tr>
                        <%= flexg.createSearchCriteriaWidget(selectedType.getAttribute("name"), selectedType, request) %>
                        </tr>
                        <%
                            out.print(flexg.generateSearchCriteriaInput(selectedType, request));
                        %>
                     <%= tg.endContentTable() %>
                     <%= tg.endTable() %>
                     <%= tg.endBorder() %>
                    </div>
                    <div id="listTabDiv">
                        <jsp:include page="<%=subURLFolder+ BOM_COLOR_CHOOSER_LIST %>" flush="true">
                            <jsp:param name="none" value="" />
                        </jsp:include>
                    </div>
<%
                   columns.clear();
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
                    column.setLinkMethod("launchImageViewer");
                    column.setLinkTableIndex("LCSCOLOR.thumbnail");
                    columns.add(column);

                    column = new TableColumn();
                    column.setDisplayed(true);
                    column.setHeaderLabel(colorLabel);
                    column.setHeaderAlign("left");
                    column.setLinkMethod("viewObjectNewWindow");
                    column.setLinkTableIndex("LCSCOLOR.IDA2A2");
                    column.setTableIndex("LCSCOLOR.COLORNAME");
                    column.setLinkMethodPrefix("OR:com.lcs.wc.color.LCSColor:");
                    column.setHeaderLink("javascript:resort('LCSColor.idA2A2')");
                    column.setUseQuickInfo(true);
                    columns.add(column);

                    columns = flexg.createSearchResultsColumns(FlexTypeCache.getFlexTypeFromPath("Color"), columns);                    
                    
%>
                <% if(quickSpec != null){ %>
                    <div id="quickSpecTabDiv">
                    <%
                    
                    Collection quickSpecColors = new LCSDocumentQuery().getDocToColorLinkData(quickSpec).getResults();
                    HashSet oidList = new HashSet();
                    Iterator iter = quickSpecColors.iterator();
                    Map obj = null;
                    while(iter.hasNext()){
                        obj = (Map) iter.next();
                        oidList.add("OR:com.lcs.wc.LCSColor:" + obj.get("DOCTOCOLORLINK.IDA3A5"));
                    }
                    
                    Collection attCols = null;
                    Map criteria = new HashMap();
                    SearchResults quickSpecColorData = new LCSColorQuery().findColorsByCriteria(criteria, 
                                                                                                FlexTypeCache.getFlexTypeFromPath("Color"),
                                                                                                attCols,
                                                                                                null,
                                                                                                oidList);
                                                
                    

                     %>
                    <%= tg.drawTable(quickSpecColorData.getResults(), columns, "", true, false) %>
                    </div>
                    <% } %>
                     <div id="favoritesTabDiv">
                        <%
                        Collection favoritesIds = new FavoriteObjectQuery().findFavoriteObjectsIdsForCurrentUser("com.lcs.wc.color.LCSColor");
                        HashSet oidList = new HashSet(favoritesIds);
                        if(oidList.size() > 0){
	                        
	                        Collection attCols = null;
	                        Map criteria = new HashMap();
	                        FlexType materialType = bomPart.getFlexType().getReferencedFlexType(ReferencedTypeKeys.MATERIAL_TYPE);                       
	                        SearchResults favoritesColorData = new LCSColorQuery().findColorsByCriteria(criteria, 
	                                FlexTypeCache.getFlexTypeFromPath("Color"),
	                                attCols,
	                                null,
	                                oidList);
	
	                                                            
	                        %>         
	                        <%= tg.drawTable(favoritesColorData.getResults(), columns, "", true, false) %>
	                    <% } %>                        
                     </div>
                </td>
            </tr>
        </table>
    </td>
</tr>
</table>
<script>
    showTab(document.MAINFORM.colorChooserTab.value);
</script>
