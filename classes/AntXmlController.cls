//ChamingaD
public without sharing class AntXmlController{

    public String lastModDateFilter  {get; set;}
    public String debug {get; set;}
    public String deployContent {get; set;}
    
    public List<String> deployItems {get; set;}
    public List<String> deployClasses {get; set;}
    public List<String> deployPages {get; set;}
    public List<String> deployComponents {get; set;}
    public List<String> deployLayouts {get; set;}
    public List<String> deployObjects {get; set;}
    public List<String> deployResources {get; set;}
    public List<String> deployTriggers {get; set;}
    public List<String> deployWorkflows {get; set;}
    public List<String> deployApprovalProcess {get; set;}
    public List<String> deployEmailTemplates {get; set;}
    public String errorHighlights {get; set;}
    
    //----
    
   public List<ApexClass> classes {get; set;}
   public List<ApexPage> pages {get; set;}
   public List<ApexTrigger> triggers {get; set;}
   public List<StaticResource> resources {get; set;}
   public List<ApexComponent> components {get; set;}
   public List<String> filesList {get; set;}
   public Map<String, String> filesMap {get; set;}
   public List<String> fileStamps  {get; set;}
   
    public AntXmlController(){
       User u = [select Id, username from User where Id = :UserInfo.getUserId()];
       String filter = ApexPages.currentPage().getParameters().get('filter');
       
       if(lastModDateFilter == null){
           lastModDateFilter = '-2';
       }
       
       GenerateFilesList();
    }
    
    public void GenerateFilesList(){
    
       filesList = new List<String>();
       filesMap = new Map<String, String>();
       deployContent = '';
                
       classes = [SELECT Name, LastModifiedDate FROM ApexClass WHERE Lastmodifieddate > :Date.today().addDays(Integer.valueOf(lastModDateFilter)) order by Lastmodifieddate desc  LIMIT 50000]; 
       pages = [SELECT Id, Name, LastModifiedDate FROM ApexPage WHERE Lastmodifieddate > :Date.today().addDays(Integer.valueOf(lastModDateFilter)) order by Lastmodifieddate desc LIMIT 5000];
       triggers = [SELECT Name, LastModifiedDate FROM ApexTrigger WHERE Lastmodifieddate > :Date.today().addDays(Integer.valueOf(lastModDateFilter)) order by Lastmodifieddate desc LIMIT 50000];
       resources= [SELECT Name, LastModifiedDate FROM StaticResource WHERE Lastmodifieddate > :Date.today().addDays(Integer.valueOf(lastModDateFilter)) order by Lastmodifieddate desc LIMIT 50000];
       components = [SELECT Name, LastModifiedDate FROM ApexComponent WHERE Lastmodifieddate > :Date.today().addDays(Integer.valueOf(lastModDateFilter)) order by Lastmodifieddate desc LIMIT 50000];
       
       Integer x = 1;
       
       x = 1;
       for (ApexClass clas : classes){
           filesList.add(clas.Name+'.cls');
           
           String lastMod = String.valueOf(clas.Lastmodifieddate);
           lastMod = lastMod.replaceAll( ':', '');
           lastMod = lastMod.replaceAll( '-', '');
           lastMod = lastMod.replaceAll( '\\s+', '');
           
           filesMap.put(String.valueOf(Double.valueOf(lastMod)+x),clas.Name+'.cls');
          
           x++;
       }
       x = 1;
       for (ApexPage page: pages){
           filesList.add(page.Name+'.page');
           
           String lastMod = String.valueOf(page.Lastmodifieddate);
           lastMod = lastMod.replaceAll( ':', '');
           lastMod = lastMod.replaceAll( '-', '');
           lastMod = lastMod.replaceAll( '\\s+', '');
           
           
           filesMap.put(String.valueOf(Double.valueOf(lastMod)+x),page.Name+'.page');
           x++;
       }
       x = 1;
       for (ApexTrigger triger: triggers){
           filesList.add(triger.Name+'.trigger');
           
           String lastMod = String.valueOf(triger.Lastmodifieddate);
           lastMod = lastMod.replaceAll( ':', '');
           lastMod = lastMod.replaceAll( '-', '');
           lastMod = lastMod.replaceAll( '\\s+', '');
           
           filesMap.put(String.valueOf(Double.valueOf(lastMod)+x),triger.Name+'.trigger');
           x++;
       }
       x = 1;
       for (StaticResource resource: resources){
           filesList.add(resource.Name+'.resource');
           
           String lastMod = String.valueOf(resource.Lastmodifieddate);
           lastMod = lastMod.replaceAll( ':', '');
           lastMod = lastMod.replaceAll( '-', '');
           lastMod = lastMod.replaceAll( '\\s+', '');
           
           filesMap.put(String.valueOf(Double.valueOf(lastMod)+x),resource.Name+'.resource');
           x++;
       }
       x = 1;
       for (ApexComponent component: components){
           filesList.add(component.Name+'.component');
           
           String lastMod = String.valueOf(component.Lastmodifieddate);
           lastMod = lastMod.replaceAll( ':', '');
           lastMod = lastMod.replaceAll( '-', '');
           lastMod = lastMod.replaceAll( '\\s+', '');
           
           filesMap.put(String.valueOf(Double.valueOf(lastMod)+x),component.Name+'.component');
           x++;
       }

       fileStamps = new List<String>(filesMap.keySet());
       fileStamps.sort();
       
       List<String> finalList = new List<String>();
        for(Integer i = fileStamps.size()-1; i>=0;i--)
        {
            finalList.add(fileStamps.get(i));
        }
        
       fileStamps = finalList;
       
       for(String timestamp: filesMap.keySet()){
           deployContent += filesMap.get(timestamp) + '\n';
       }
    }

    public void GenerateXML(){
        deployItems = new List<String>(); 
        deployClasses = new List<String>(); 
        deployPages= new List<String>(); 
        deployComponents = new List<String>(); 
        deployLayouts= new List<String>(); 
        deployObjects= new List<String>();
        deployResources= new List<String>();
        deployTriggers= new List<String>();
        deployWorkflows = new List<String>();
        deployApprovalProcess = new List<String>();
        deployEmailTemplates = new List<String>();
    
        Set<String> tempItems = new Set<String>();
        
        deployItems = deployContent.split('\n');
        tempItems.addAll(deployItems);
        deployItems.clear();
        deployItems.addAll(tempItems);
        errorHighlights = '';

        for (String item : deployItems){
            item = item.trim(); 
            String[] itemSplit = item.split('\\.');
            
            if (itemSplit !=null && itemSplit.size() > 1){
                if(itemSplit[1].trim()=='cls'){
                    deployClasses.add(itemSplit[0].trim());
                }else if (itemSplit[1].trim()=='page'){
                    deployPages.add(itemSplit[0].trim());
                }else if (itemSplit[1].trim()=='component'){
                    deployComponents.add(itemSplit[0].trim());
                }else if (itemSplit[1].trim()=='layout'){
                    deployLayouts.add(itemSplit[0].trim());
                }else if (itemSplit[1].trim()=='object'){
                    deployObjects.add(itemSplit[0].trim());
                }else if (itemSplit[1].trim()=='resource'){
                    deployResources.add(itemSplit[0].trim());
                }else if (itemSplit[1].trim()=='trigger'){
                    deployTriggers.add(itemSplit[0].trim());
                }else if (itemSplit[1].trim()=='workflow'){
                    deployWorkflows.add(itemSplit[0].trim());
                }else if (itemSplit.size() > 2 && itemSplit[2].trim()=='approvalProcess'){
                    deployApprovalProcess.add(itemSplit[0].trim()+'.'+itemSplit[1].trim());
                }else if (itemSplit[1].trim()=='email'){
                    deployEmailTemplates.add(itemSplit[0].trim());
                }else{
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Error: Invalid Input - ' + itemSplit[0].trim() + '.' + itemSplit[1].trim()));
                    
                    errorHighlights = errorHighlights + '\'' + item + '\\n\',';
                }
                

            }else if (String.valueof(itemSplit).trim().length() > 2){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Error: Invalid Input - '+ String.valueOf(itemSplit)));
                
                errorHighlights = errorHighlights + '\'' +String.valueOf(itemSplit) + '\\n\',';
            }
        }

    } 
    
    public List<SelectOption> getDateFilters()  
    {  
            List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('-2','Yesterday'));
            options.add(new SelectOption('-3','Day Before Yesterday'));
            options.add(new SelectOption('-8','This Week'));
            options.add(new SelectOption('-999','Begining'));
            return options;
        }
  
}