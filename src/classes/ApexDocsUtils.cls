public class ApexDocsUtils
{
    public static final string AP3XDOCS_NAMESPACE = 'ap3xdocs';

    public static list<SelectOption> getSelectOptions(list<sObject> objects, final string fieldForLabel)
    {
        return getSelectOptions(objects, fieldForLabel, false);
    }

    public static list<SelectOption> getSelectOptions(final list<sObject> objects, final string fieldForLabel, final boolean addBlank)
    {
        final list<SelectOption> options = new list<SelectOption>();
/*
        if (addBlank)
        {
            options.add(getBlankSelectOption());
        }
 */
        for (sObject obj : objects)
        {
            options.add(new SelectOption(obj.id, (string) obj.get(fieldForLabel)));
        }

        return options;
    }

    public static map<string, sobject> generateMapFromField(final list<sobject> sobjects, final string stringFieldToBeKey)
    {
        map<string, sobject> outputMap = new map<string, sobject>();

        for (sobject sobj : sobjects)
        {
            outputMap.put((string)sobj.get(stringFieldToBeKey), sobj);
        }

        return outputMap;
    }

    public static string getApexDocsFileName(final string className)
    {
        return 'ApexDocModelData-' + className + '.json';
    }

    /*************************************************************************
     * @param str - string to search
     * @param iSearch - where to start searching backwards from
     * @return the previous word, or null if none found.
     */
    public static string strPrevWord (string str, integer iSearch)
    {
        if (str == null)
            return null;
        if (iSearch >= str.length())
            return null;

        integer iStart;
        integer iEnd;
        for (iStart = iSearch-1, iEnd = 0; iStart >= 0; iStart--)
        {
            if (iEnd == 0)
            {
                if (str.substring(iStart,iStart+1) == ' ')
                    continue;
                iEnd = iStart+1;
            }
            else if (str.substring(iStart,iStart+1) == ' ')
            {
                iStart++;
                break;
            }
        }

        if (iStart == -1)
            return null;
        else
            return str.substring(iStart, iEnd).trim();
    }

}