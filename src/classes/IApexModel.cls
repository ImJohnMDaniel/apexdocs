/**
 *  IApexModel
 *
 *  @author John M. Daniel
 *  @see ClassModel
 *  @see InterfaceModel
 */
public interface IApexModel
{
    void set(final string tag, final string value);
    /**
     * @param a string value which represents the name line
     * @see ClassModel
     */
    void setNameLine(final string value);

    /**
     *  @return the file name
     */
    string getName();
}