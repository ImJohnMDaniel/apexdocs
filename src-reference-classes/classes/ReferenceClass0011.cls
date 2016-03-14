/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 *
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class ReferenceClass0011
{
    @IsTest
    private static void callingDomainFactoryShouldGiveRegisteredImplsAndMocks()
    {
        // Registered Accounts domain class by SObject List
        Id testAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        fflib_ISObjectDomain domainObjectAcct =
            Domain.newInstance(
                new List<Account>
                    { new Account(
                        Id = testAccountId,
                        Name = 'Test Account') });
        System.assert(domainObjectAcct instanceof AccountsDomain);
        System.assertEquals(testAccountId, domainObjectAcct.getRecords()[0].Id);

        // Registered Accounts domain class by SObject List
        testAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        domainObjectAcct =
            Domain.newInstance(
                new List<SObject>
                    { new Account(
                        Id = testAccountId,
                        Name = 'Test Account') }
                , Account.SObjectType);
        System.assert(domainObjectAcct instanceof AccountsDomain);
        System.assertEquals(testAccountId, domainObjectAcct.getRecords()[0].Id);

        // Registered Opportunities domain class by SObject List
        Id testOpportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        fflib_ISObjectDomain domainObjectOpp =
            Domain.newInstance(
                new List<Opportunity>
                    { new Opportunity(
                        Id = testOpportunityId,
                        Name = 'Test Opportunity') });
        System.assertEquals(testOpportunityId, domainObjectOpp.getRecords()[0].Id);
        System.assert(domainObjectOpp instanceof OpportuntiesDomain);

        // Test failure for creating new instance using IConstructable2
        // for domain class that does not support it
        testOpportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        domainObjectOpp =
            Domain.newInstance(
                new List<SObject>
                    { new Opportunity(
                        Id = testOpportunityId,
                        Name = 'Test Opportunity') }
                , Opportunity.SObjectType);
        System.assertEquals(testOpportunityId, domainObjectOpp.getRecords()[0].Id);
        System.assert(domainObjectOpp instanceof OpportuntiesDomain);

        // Given
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        mocks.startStubbing();
        fflib_ISObjectDomain domainMock = new fflib_SObjectMocks.SObjectDomain(mocks);
        mocks.when(domainMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.stopStubbing();
        Domain.setMock(domainMock);

        // When
        domainObjectAcct =
            Domain.newInstance(
                new List<Account>
                    { new Account(
                        Id = testAccountId,
                        Name = 'Test Account') });

        // Then
        System.assert(domainObjectAcct instanceof fflib_SObjectMocks.SObjectDomain);

        // When
        domainObjectAcct =
            Domain.newInstance(
                new List<SObject>
                    { new Account(
                        Id = testAccountId,
                        Name = 'Test Account') }
                , Account.SObjectType);

        // Then
        System.assert(domainObjectAcct instanceof fflib_SObjectMocks.SObjectDomain);
    }

    @IsTest
    private static void callingDomainFactoryWithIdsShouldGiveRegisteredImpls()
    {
        // Given
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        mocks.startStubbing();
        fflib_ISObjectSelector selectorMock = new fflib_SObjectMocks.SObjectSelector(mocks);
        Id testAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        List<Account> accounts =
            new List<Account>
                { new Account(
                    Id = testAccountId,
                    Name = 'Test Account') };
        Set<Id> accountIds = new Map<Id, Account>(accounts).keySet();
        mocks.when(selectorMock.selectSObjectsById(accountIds)).thenReturn(accounts);
        mocks.when(selectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.stopStubbing();

        // When
        Selector.setMock(selectorMock);
        fflib_ISObjectDomain domainObjectAcc = Domain.newInstance(new Set<Id> { testAccountId });

        // Then
        List<Account> assertAccounts = (List<Account>) domainObjectAcc.getRecords();
        System.assert(domainObjectAcc instanceof AccountsDomain);
        System.assertEquals(testAccountId, domainObjectAcc.getRecords()[0].Id);
        System.assertEquals(1, assertAccounts.size());
        System.assertEquals(testAccountId, assertAccounts[0].Id);
        System.assertEquals('Test Account', assertAccounts[0].Name);
    }
    // Configure and create the SelectorFactory for this Application
    public static final fflib_Application.SelectorFactory Selector =
        new fflib_Application.SelectorFactory(
            new Map<SObjectType, Type> { });

    // Configure and create the DomainFactory for this Application
    public static final fflib_Application.DomainFactory Domain =
        new fflib_Application.DomainFactory(
            ReferenceClass0011.Selector,
            new Map<SObjectType, Type> {
                    Account.SObjectType => AccountsConstructor.class,
                    Opportunity.SObjectType => OpportuntiesConstructor.class
                     });

    public class AccountsDomain extends fflib_SObjectDomain
    {
        public AccountsDomain(List<Account> sObjectList)
        {
            super(sObjectList);
        }

        public AccountsDomain(List<SObject> sObjectList, SObjectType sObjectType)
        {
            super(sObjectList, sObjectType);
        }
    }

    public class AccountsConstructor implements fflib_SObjectDomain.IConstructable2
    {
        public fflib_SObjectDomain construct(List<SObject> sObjectList)
        {
            return new AccountsDomain(sObjectList);
        }

        public fflib_SObjectDomain construct(List<SObject> sObjectList, SObjectType sObjectType)
        {
            return new AccountsDomain(sObjectList, sObjectType);
        }
    }

    public class OpportuntiesDomain extends fflib_SObjectDomain
    {
        public OpportuntiesDomain(List<Opportunity> sObjectList)
        {
            super(sObjectList);
        }

        public OpportuntiesDomain(List<SObject> sObjectList, SObjectType sObjectType)
        {
            super(sObjectList, sObjectType);
        }
    }

    private class DontDocumentMeBecauseIAmPrivate
    {

    }

    public class OpportuntiesConstructor implements fflib_SObjectDomain.IConstructable2
    {
        public fflib_SObjectDomain construct(List<SObject> sObjectList)
        {
            return new OpportuntiesDomain(sObjectList);
        }

        public fflib_SObjectDomain construct(List<SObject> sObjectList, SObjectType sObjectType)
        {
            return new OpportuntiesDomain(sObjectList, sObjectType);
        }
    }
}