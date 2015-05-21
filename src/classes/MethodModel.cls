/**
 *  TheMethodModel
 *  @author John M. Daniel
 *  @date 4 MARCH 2015
 *  @Description This is the MethodModel.  It holds the references to
 *      the methods of a class
 *  @see ApexConstructBaseModel
 *  @see IApexModel
 *  @see IParams
 */
public class MethodModel
    extends ApexConstructBaseModel
    implements IApexModel, IParams, IThrows
{
    private list<string> params = new list<string>();
    private string returnType;
    private list<ClassLinkModel> exceptionsThrown = new list<ClassLinkModel>();

    public override type getClassType()
    {
        return MethodModel.class;
    }

    public void setReturnType( final string returnType )
    {
    	this.returnType = returnType;
    }

    public string getReturnType()
    {
    	return this.returnType;
    }

    public void setParams( final list<string> params )
    {
        this.params = params;
    }

    public list<string> getParams()
    {
        return this.params;
    }

    public void setThrows( final list<ClassLinkModel> exceptionsThrown )
    {
        this.exceptionsThrown = exceptionsThrown;
    }

    /**
     *  getExceptionsThrown
     *
     *  This method returns all of the exceptions that are thrown from the method model.
     *  @return list<ClassLinkModel> representing list of exceptions thrown.
     * @see ClassLinkModel
     *  @throws Exception
     */
    public list<ClassLinkModel> getThrows()
    {
        return this.exceptionsThrown;
    }

    public override void setNameLine(string nameLine)
    {
        //system.debug('METHOD SETTING OF NAMELINE == '+nameLine);
        // remove anything after the parameter list
        if (nameLine != null)
        {
            integer i = nameLine.lastIndexOf(')');
            if (i >= 0)
                nameLine = nameLine.substring(0, i+1);
        }
        nameLine = nameLine;
        //system.debug('METHOD SETTING OF NAMELINE == '+nameLine);
        super.setNameLine(nameLine);
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
                    string methodName = ApexDocsUtils.strPrevWord(nameLine, lastindex);
                    return methodName;
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
        else if (tag == 'see')
        {
            this.addSee(value);
        }
        else if (tag == 'return')
        {
            this.setReturnType(value);
        }
        else if (tag == 'throws' || tag == 'throw' || tag == 'exception')
        {
            this.getThrows().add(new ClassLinkModel(ClassLinkModel.ClassLinkTypes.THROWING, value));
        }
        else if (tag == 'param')
        {
            this.getParams().add(value);
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
/*
    public override string toString()
    {
    	return 'MethodModel: '+getMethodName()+'\n'
    	       +'\t'+this.getNameLine()+'\n'
    	       +'\t'+this.getSees()+'\n'
               +'\t'+this.getParams()+'\n'
               +'\t'+this.getSince()+'\n'
               +'\t'+this.getDate()+'\n'
               +'\t'+this.getReturnType()+'\n'
               +'\t'+this.getDescription()+'\n'
    	       ;
    }
*/
}