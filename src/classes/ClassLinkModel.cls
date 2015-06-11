/**
 * ClassLinkModel
 * @description This is the domain model that reflects a link to another class
 * @since 1.0
 * @date 15 MARCH 2015
 * @author John M. Daniel
 */
public class ClassLinkModel
{
	public enum ClassLinkTypes
	{
		EXTENDING, IMPLEMENTING, SEEING, THROWING, DESCRIPTION, OUTERCLASS, INNERCLASS
	}

    private ClassLinkModel.ClassLinkTypes linkType;
    private string name;
    private string url;
    private string fromName;
    private string fromUrl;

    // make the default constructor private so that it will force usage of the other constructor.
    private ClassLinkModel() {}

    public static ClassLinkModel.ClassLinkTypes getTypeByName(final string typeName)
    {
    	ClassLinkModel.ClassLinkTypes theType = null;

    	for (ClassLinkModel.ClassLinkTypes aType : ClassLinkModel.ClassLinkTypes.values())
    	{
    		if (aType.name() == typeName)
    		{
    			theType = aType;
    			break;
    		}
    	}

    	return theType;
    }

    /**
     *  The main constructor
     *  @date 18 MARCH 2015
     *  @param the link type expressed as one of the ClassLinkModel.ClassLinkTypes ENUM values
     *  @param the string name of the class that this links to.
     */
    public ClassLinkModel (final ClassLinkModel.ClassLinkTypes linkType, final string name)
    {
    	this.linkType = linkType;
    	this.name = name;
    	// If the "name" is actually a true weblink...
		try
		{
		    Url u  = new url( name );
		    // if the above works, then it is a weblink
		    this.url = name;
		}
		catch ( System.StringException se )
		{
            // the string exception would occur if it is not a true weblink
            // do nothing because it is a Apec Class reference instead
		}
    }

    public ClassLinkModel.ClassLinkTypes getLinkType()
    {
    	return this.linkType;
    }

    public string getFromName()
    {
        return this.fromName;
    }

    /**
     *  @return a string value representing the url of the class that the link is from
     *  @throws Exception
     */
    public string getFromUrl()
    {
        return this.fromUrl;
    }

    public string getName()
    {
        return this.name;
    }

    /**
     *  @return a string value representing the url
     *  @throws Exception
     */
    public string getUrl()
    {
        return this.url;
    }

    public boolean isLinkResolved()
    {
        return this.url != null;
    }

    public boolean getIsLinkResolved()
    {
        return isLinkResolved();
    }

    public void setLinkType(final ClassLinkModel.ClassLinkTypes linkType)
    {
    	this.linkType = linkType;
    }

    public void setFromName(final string name)
    {
        this.fromName = name;
    }

    public void setFromUrl(final string url)
    {
        this.fromUrl = url;
    }

    public void setName(final string name)
    {
        this.name = name;
    }

    public void setUrl(final string url)
    {
        this.url = url;
    }

}