/**
 *  IParams
 *  @author John M. Daniel
 *  @date 9 MARCH 2015
 *  @description This is the IParams.  It sets the contract for
 *      the param annotation.
 *  @since 1.0
 */
public interface IParams
{
	/**
	 * @param list of strings.  One for each parameter.
	 */
    void setParams( final list<string> params );

    /**
     * @return a list of strings
     */
    list<string> getParams();
}