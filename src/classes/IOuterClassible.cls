/**
 *  This interface specifies the how to retrieve information about the "outer" class
 *  that this inner class would belong to.
 *  @author John M. Daniel
 *  @date 10 JUNE 2015
 *  @since 1.0
 *  @see ClassLinkModel
 */
public interface IOuterClassible
{
    /**
     * @param the ClassLinkModel representing the outer class that this class is a part of.
     */
    void setOuterClass( final ClassLinkModel params );

    /**
     * @return the ClassLinkModel representing the outer class that this class is a part of.
     */
    ClassLinkModel getOuterClass();
}