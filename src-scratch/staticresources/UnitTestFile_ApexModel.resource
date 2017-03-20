public abstract class ApexModel implements ISees
{
	private string nameLine = null;
    private string description = null;
    private string dateValue = null;
    private boolean deprecated = false;
    private string since = null;

    private list<ClassLinkModel> sees = new list<ClassLinkModel>();

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

    public virtual string getDescription()
    {
    	return this.description;
    }

    public virtual void setDescription(final string description)
    {
    	this.description = description;
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
