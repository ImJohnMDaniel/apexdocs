/**
 *  IImplementable
 *  @author John M. Daniel
 *  @date 7 MARCH 2015
 *  @description This is the IImplementable.
 *  @since 1.0
 *  @see ClassLinkModel
 */
public interface IImplementable
{
    /**
     * @param the list<ClassLinkModel> representing the classes or interfaces that the parent file is implementing.
     */
	void setInterfacesImplemented(final list<ClassLinkModel> interfacesImplemented);

    /**
     * @return the list<ClassLinkModel> representing the classes or interfaces that the parent file is implementing.
     */
	list<ClassLinkModel> getInterfacesImplemented();

}