public abstract class ApexConstructBaseModel
    implements ISees, IDescriptionLinks
{
    private string nameLine = null;
    private string dateValue = null;
    private boolean deprecated = false;
    private string since = null;

    private list<string> descriptionLines = new list<string>();

    private list<ClassLinkModel> sees = new list<ClassLinkModel>();
    private list<ClassLinkModel> descriptionLinks = new list<ClassLinkModel>();

    public abstract type getClassType();

    public boolean isTestMethod()
    {
        return false;
    }

    public virtual string getNameLine()
    {
        return this.nameLine;
    }

    public virtual void setNameLine(final string nameLine)
    {
        this.nameLine = nameLine;
    }

    public virtual string getSince()
    {
        return this.since;
    }

    public virtual void setSince(final string since)
    {
        this.since = since;
    }

    public virtual list<String> getDescriptionLines()
    {
        return this.descriptionLines;
    }

    public virtual string getDescription()
    {
        string output = '';

        map<string, ClassLinkModel> descriptionLinksAvailableMap = new map<string, ClassLinkModel>();

        for (ClassLinkModel descriptionLink : this.descriptionLinks)
        {
            descriptionLinksAvailableMap.put( descriptionLink.getName(), descriptionLink );
        }

        string descriptionLineWithLinkResolved = null;

        for (string descriptionLine : descriptionLines)
        {
            if (descriptionLine.containsIgnoreCase('@link')
                && descriptionLinksAvailableMap.containsKey(descriptionLine.substringBetween('{','}').replace('@link','').normalizeSpace())
                )
            {
                string linkItem = descriptionLine.substringBetween('{','}').replace('@link','').normalizeSpace();

                if (descriptionLinksAvailableMap.get(linkItem).isLinkResolved())
                {
                    descriptionLineWithLinkResolved = descriptionLine.replace('{' + descriptionLine.substringBetween('{','}') + '}', '<a href="'+descriptionLinksAvailableMap.get(linkItem).getUrl()+'">'+linkItem+'</a>');
                }
                else
                {
                    descriptionLineWithLinkResolved = descriptionLine.replace('{' + descriptionLine.substringBetween('{','}') + '}', linkItem);
                }
            }
            else
            {
                descriptionLineWithLinkResolved = descriptionLine;
            }

            output += descriptionLineWithLinkResolved + ' ';
        }


        return output;
    }

    public virtual void addDesciptionLine(final string descriptionLine)
    {
        this.descriptionLines.add( descriptionLine );
    }

    public virtual list<ClassLinkModel> getSees()
    {
        return this.sees;
    }

    public virtual void addSee(final string value)
    {
        this.sees.add(new ClassLinkModel(ClassLinkModel.ClassLinkTypes.SEEING, value));
    }

    public virtual void setSees(final list<ClassLinkModel> sees)
    {
        this.sees = sees;
    }

    public virtual list<ClassLinkModel> getDescriptionLinks()
    {
        return this.descriptionLinks;
    }

    public virtual void addDescriptionLink(final string value)
    {
        this.descriptionLinks.add(new ClassLinkModel(ClassLinkModel.ClassLinkTypes.DESCRIPTION, value));
    }

    public virtual void setDescriptionLinks(final list<ClassLinkModel> descriptionLinks)
    {
        this.descriptionLinks = descriptionLinks;
    }

    public virtual string getDate()
    {
        return this.dateValue;
    }

    public virtual void setDate(final string dateValue)
    {
        this.dateValue = dateValue;
    }

    public virtual boolean getDeprecated()
    {
        return this.deprecated;
    }

    public virtual void setDeprecated(final boolean deprecated)
    {
        this.deprecated = deprecated;
    }
}