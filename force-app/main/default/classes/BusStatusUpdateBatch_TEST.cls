@isTest
public class BusStatusUpdateBatch_TEST 
{
    @isTest
    static void BusStatusUpdateBatch_TEST() 
    {
        List<Bus__c> busesList = new List<Bus__c>();
        List<Passenger__c> passengersList = new List<Passenger__c>();

        for (Integer i = 0; i < 200; i++) 
        {
            busesList.add(new Bus__c(
                Name = 'Bus ' + i
            ));
        }

        insert busesList;

        for (Bus__c bus : busesList) 
        {
            Integer passengerCount = Math.mod(Crypto.getRandomInteger(), 26); 
            if (passengerCount < 0)
            {
                passengerCount *= -1;
            }

            for (Integer j = 0; j < passengerCount; j++) 
            {
                passengersList.add(new Passenger__c(
                    Name = 'P' + bus.Name.split(' ')[1] + '-' + j,
                    Bus__c = bus.Id
                ));
            }
        }

        insert passengersList;

        List<Id> busIdsList = new List<Id>();
        for (Bus__c bus : busesList) 
        {
            busIdsList.add(bus.Id);
        }

        Test.startTest();
            BusStatusUpdateBatch batch = new BusStatusUpdateBatch(busIdsList);
            Database.executeBatch(batch, 200);
        Test.stopTest();

        busesList = [SELECT Name, Bus_Status__c, Passenger_Count__c FROM Bus__c ORDER BY Name];

        for (Bus__c bus : busesList) 
        {
            Integer count = bus.Passenger_Count__c != null ? Integer.valueOf(bus.Passenger_Count__c) : 0;

            if (count > 20) 
            {
                Assert.areEqual(null, bus.Bus_Status__c, 'Bus with >20 passengers should not be updated: ' + bus.Name);
            } 
            else if (count == 20) 
            {
                Assert.areEqual('Full', bus.Bus_Status__c, 'Bus with 20 passengers should be Full: ' + bus.Name);
            } 
            else if (count > 10) 
            {
                Assert.areEqual('Limited Seats', bus.Bus_Status__c, 'Bus with 11-19 passengers should be Limited Seats: ' + bus.Name);
            } 
            else 
            {
                Assert.areEqual('Available', bus.Bus_Status__c, 'Bus with <10 passengers should be Available: ' + bus.Name);
            }
        }
    }

    @isTest
    static void BusStatusUpdateBatch_EmptyList_TEST()
    {
        List<Id> busIdsList = new List<Id>();

        Test.startTest();
            BusStatusUpdateBatch batch = new BusStatusUpdateBatch(busIdsList);
            Database.executeBatch(batch, 200);
        Test.stopTest();
    }
}
