/**
 * Copyright (c) 2014, FinancialForce.com, inc
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification,
 *   are permitted provided that the following conditions are met:
 *
 * - Redistributions of source code must retain the above copyright notice,
 *      this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright notice,
 *      this list of conditions and the following disclaimer in the documentation
 *      and/or other materials provided with the distribution.
 * - Neither the name of the FinancialForce.com, inc nor the names of its contributors
 *      may be used to endorse or promote products derived from this software without
 *      specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 *  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 *  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
 *  THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 *  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 *  OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 *  OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 *  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
**/

/**
 * Class provides inner classes implementing factories for the main components
 * of the Apex Enterprise Patterns, Service, Unit Of Work, Selector and Domain.
 *   See the sample applications Application.cls file for an example
 **/
public class Sample
{
    /**
     * Class implements a Unit of Work factory
     **/
    public class UnitOfWorkFactory
    {
        private List<SObjectType> m_objectTypes;
        private fflib_ISObjectUnitOfWork m_mockUow;

        /**
         * Constructs a Unit Of Work factory
         *
         * @param objectTypes List of SObjectTypes in dependency order
         **/
        public UnitOfWorkFactory(List<SObjectType> objectTypes)
        {
            m_objectTypes = objectTypes.clone();
        }

        /**
         * Returns a new fflib_SObjectUnitOfWork configured with the
         *   SObjectType list provided in the constructor, returns a Mock implementation
         *   if set via the setMock method
         **/
        public fflib_ISObjectUnitOfWork newInstance()
        {
            // Mock?
            if(m_mockUow!=null)
                return m_mockUow;
            return new fflib_SObjectUnitOfWork(m_objectTypes);
        }

        @TestVisible
        private void setMock(fflib_ISObjectUnitOfWork mockUow)
        {
            m_mockUow = mockUow;
        }
    }
}