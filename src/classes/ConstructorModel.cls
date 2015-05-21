public class ConstructorModel
    extends ApexConstructBaseModel
    implements IApexModel, IParams
{
    private list<string> params = new list<string>();

    public override type getClassType()
    {
    	return ConstructorModel.class;
    }

    public void setParams( final list<string> params )
    {
        this.params = params;
    }

    public list<string> getParams()
    {
        return this.params;
    }

    public string getName()
    {
        if (getNameLine() != null)
        {
            string nameLine = getNameLine().trim();

            if(nameLine != null && nameLine.length() > 0 )
            {
                integer lastindex = nameLine.indexOf('(');
                if (lastindex >= 0)
                {
                    return ApexDocsUtils.strPrevWord(nameLine, lastindex);
                }
            }
        }
        return '';

    }

    public void set(final string tag, final string value)
    {
        if (tag == 'description')
        {
            //this.setDescription( ( this.getDescription() == null ? '' : this.getDescription() + ' ' ) + value );
            this.addDesciptionLine( value );
        }
        else if (tag == 'param')
        {
            this.getParams().add(value);
        }
        else if (tag == 'see')
        {
            this.addSee(value);
        }
        else if (tag == 'since')
        {
            this.setSince(value);
        }
        else if (tag == 'date')
        {
            this.setDate(value);
        }
    }
}