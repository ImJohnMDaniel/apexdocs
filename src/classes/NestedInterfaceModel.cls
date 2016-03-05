/**
 *  NestedInterfaceModel
 *  @author John M. Daniel
 *  @date 4 MARCH 2015
 *  @Description This is the NestedInterfaceModel.  It holds the references to
 *      an interface.
 *
 */
public class NestedInterfaceModel extends ApexConstructBaseModel
    implements IApexModel, IFile, IMethods, IAuthorable
            , IExtensible, IOuterClassible
{
    public override type getClassType()
    {
        return NestedInterfaceModel.class;
    }

    private id apexFileId;
    private id codeInfoId;
    private id codeInfoAttachmentId;

    private boolean isModelCurrent = false;

    private ClassLinkModel extendsInterface = null;
    private ClassLinkModel outerClass = null;
    private list<MethodModel> methods = new list<MethodModel>();
    private list<string> authors = new list<string>();

    public id getApexFileId()
    {
        return this.apexFileId;
    }

    public list<string> getAuthors()
    {
        return this.authors;
    }

    public id getCodeInfoAttachmentId()
    {
        return this.codeInfoAttachmentId;
    }

    public ClassLinkModel getExtends()
    {
        return this.extendsInterface;
    }

    public id getId()
    {
        return this.codeInfoId;
    }

    public boolean getIsInterface()
    {
        return true;
    }

    public string getName()
    {
        string nameLine = getNameLine();

        if (nameLine != null) nameLine = nameLine.trim();
        //system.debug('@@ File Name = ' + nameLine);

        if(nameLine != null && nameLine.trim().length() > 0 )
        {
            string interfaceKeywordToFind = ' interface ';
            //system.debug('## File Name = ' + nameLine.trim().lastIndexOf(' '));
            integer fFound = nameLine.indexOf(interfaceKeywordToFind);
            integer lFound = nameLine.indexOf(' ', fFound + interfaceKeywordToFind.length());

            if (lFound == -1)
                return nameLine.substring(fFound + interfaceKeywordToFind.length());

            try
            {
                String name = nameLine.substring(fFound + interfaceKeywordToFind.length(), lFound);
                return name;
            }
            catch (Exception ex)
            {
                return nameLine.substring(nameLine.lastIndexOf(' ') + 1);
            }
        }
        else
        {
            return '';
        }
    }

    public list<MethodModel> getMethods()
    {
        return this.methods;
    }

    public ClassLinkModel getOuterClass()
    {
        return this.outerClass;
    }

    public void set(final string tag, final string value)
    {
        if (tag == 'description')
        {
            //this.setDescription( ( this.getDescription() == null ? '' : this.getDescription() + ' ' ) + value );
            this.addDesciptionLine( value );
        }
        else if (tag == 'author')
        {
            this.getAuthors().add(value);
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
        else if (tag == 'deprecated')
        {
            this.setDeprecated(true);
        }
    }

    public void setApexFileId(final id id)
    {
        this.apexFileId = id;
    }

    public void setAuthor(final string author)
    {
        this.authors.add(author);
    }

    public void setAuthor(final list<string> authors)
    {
        this.authors = authors;
    }

    public void setCodeInfoAttachmentId(final id codeInfoAttachmentId)
    {
        this.codeInfoAttachmentId = codeInfoAttachmentId;
    }

    public void setExtends(final ClassLinkModel extendsInterface)
    {
        this.extendsInterface = extendsInterface;
    }

    public void setId(final id codeInfoId)
    {
        this.codeInfoId = codeInfoId;
    }

    public void setMethods(final list<MethodModel> methods)
    {
        this.methods = methods;
    }

    /**
     *  Method is used to determine if the model information currently stored is up to date or
     *  has there been an update to the Apex Class since the last documentation event.
     *  @return boolean - true if the Apex Class and documented model information are in sync.
     */
    public boolean getIsModelCurrent()
    {
        return this.isModelCurrent;
    }

    /**
     *  convenience method to return same information as the getIsModelCurrent() method.
     */
    public boolean isModelCurrent()
    {
        return this.isModelCurrent;
    }

    public void setOuterClass( final ClassLinkModel outerClass )
    {
        this.outerClass = outerClass;
    }

    /**
     *  Setter method for the isModelCurrent value
     */
    public void setIsModelCurrent(final boolean isModelCurrent)
    {
        this.isModelCurrent = isModelCurrent;
    }
}