
@isTest
private class BusCompanyActions_TEST 
{

    @isTest
    static void BusCompanyActions_TEST() 
    {
        Bus_Company__c busCompany = new Bus_Company__c(
            Name = 'Test Bus Company'
        );
        insert busCompany;

        List<Bus__c> busesList = new List<Bus__c>();
        for (Integer i = 0; i < 4; i++) 
        {
            busesList.add(new Bus__c(
                Name = 'Bus ' + i, 
                Bus_Company__c = busCompany.Id
            ));
        }
        insert busesList;

        Test.startTest();
        List<Bus__c> busesWithPassengers = BusCompanyActions.getBusesWithPassengers(busCompany.Id);
        Test.stopTest();

        Assert.areEqual(4, busesWithPassengers.size(), 'Should retrieve 4 buses');
    }

    @isTest
    static void BusCompanyActions_NullId_TEST() 
    {
        Test.startTest();
        List<Bus__c> busesWithPassengers = BusCompanyActions.getBusesWithPassengers(null);
        Test.stopTest();

        Assert.areEqual(0, busesWithPassengers.size(), 'Should retrieve 0 buses for null ID');
    }
}