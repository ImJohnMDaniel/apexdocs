/**
 *  PropertyModel
 *  @author John M. Daniel
 *  @date 4 MARCH 2015
 *  @Description This is the PropertyModel.  It holds the reference to
 *      a property of a class
 *
 */
public class PropertyModel
    extends ApexConstructBaseModel
    implements IApexModel
{
    public override type getClassType()
    {
        return PropertyModel.class;
    }

    public override void setNameLine(string nameLine)
    {
        if (nameLine != null)
        {
            // remove any trailing stuff after property name. { =
            integer i = nameLine.indexOf('{');
            if (i == -1) i = nameLine.indexOf('=');
            if (i == -1) i = nameLine.indexOf(';');
            if (i >= 0) nameLine = nameLine.substring(0, i);

        }
        super.setNameLine(nameLine);
    }

    public string getName()
    {
        string nameLine = getNameLine().trim();

        if ( nameLine != null && nameLine.length() > 0 )
        {
            integer lastindex = nameLine.lastIndexOf(' ');

            if ( lastindex >= 0 )
            {
                string propertyName = nameLine.substring(lastindex + 1);
                return propertyName;
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
    }
}