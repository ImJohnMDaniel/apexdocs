/**
 *  ApexDocsConfigHelper
 *  @author: John Daniel
 *  @date: 24 MARCH 2015
 *  @description: This class has a series of convenience methods for interacting with
 *      the ApexDocsConfig__c custom setting.
 *
 */
public class ApexDocsConfigHelper
{
    /**
     *   Enum representing each of various application setting types
     */
    public enum Type
    {
        CORE_APEX_LINKS
    }

    private static ApexDocsConfigHelper.Type getTypeByName(final string name)
    {
    	for (ApexDocsConfigHelper.Type theType : ApexDocsConfigHelper.Type.values())
    	{
    		if (theType.name() == name)
    		{
    			return theType;
    		}
    	}
    	throw new ApexDocsConfigHelperException('Unknown ApexDocsConfigHelper.Type requested with string of \''+name+'\'');
    }

    private static final map<ApexDocsConfigHelper.Type, map<string, string>> appSettingsMap = new map<ApexDocsConfigHelper.Type, map<string, string>>();
    private static final map<ApexDocsConfigHelper.Type, list<ApexDocsConfig__c>> appSettingsListMap = new map<ApexDocsConfigHelper.Type, list<ApexDocsConfig__c>>();

    static
    {
    	ApexDocsConfigHelper.Type theType = null;

    	for (ApexDocsConfig__c appSetting : ApexDocsConfig__c.getAll().values())
    	{
    		theType = getTypeByName(appSetting.Type__c);

    		if ( ! appSettingsMap.containsKey(theType) )
    		{
    			appSettingsMap.put(theType, new map<string, string>());
    			appSettingsListMap.put(theType, new list<ApexDocsConfig__c>());
    		}

    		appSettingsMap.get(theType).put(appSetting.Key__c.toLowerCase(), appSetting.Value__c);
    		appSettingsListMap.get(theType).add(appSetting);
    	}

    }

    public static map<string, string> getSettingsForType(final ApexDocsConfigHelper.Type selectedType)
    {
    	return appSettingsMap.get(selectedType) == null ? new map<string, string>() : appSettingsMap.get(selectedType);
    }

    public static list<ApexDocsConfig__c> getSettingListForType(final ApexDocsConfigHelper.Type selectedType)
    {
    	list<ApexDocsConfig__c> settingsThatAreSorted = new list<ApexDocsConfig__c>();
    	map<integer, ApexDocsConfig__c> primerMap = new map<integer, ApexDocsConfig__c>();
    	list<integer> listKeys = new list<integer>();

    	// setup the primerMap
    	for(ApexDocsConfig__c appSetting : appSettingsListMap.get(selectedType))
    	{
    		primerMap.put(integer.valueOf(appSetting.SortOrder__c), appSetting);
    	}

    	// get the list keys which are the object's sort order fields
    	listKeys.addAll(primerMap.keySet());

    	// sort the key list
    	listKeys.sort();

    	// setup the output list in the proper sorted order
    	for(integer key : listKeys)
    	{
    		settingsThatAreSorted.add(primerMap.get(key));
    	}

    	// now return this list
    	return settingsThatAreSorted;
    }

    public class ApexDocsConfigHelperException extends Exception { }

}