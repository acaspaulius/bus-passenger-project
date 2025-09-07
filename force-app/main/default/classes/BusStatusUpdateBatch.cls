public with sharing class BusStatusUpdateBatch implements Database.Batchable<Id>, Database.Stateful 
{
    public class PassengersException extends Exception {}

    private List<Id> busIdsList;

    public BusStatusUpdateBatch(List<Id> busIdsList) 
    {
        this.busIdsList = (busIdsList != null) ? busIdsList : new List<Id>();
    }

    public Iterable<Id> start(Database.BatchableContext bc) 
    {
        return busIdsList;
    }

    public void execute(Database.BatchableContext bc, List<Id> scope) 
    {
        if (scope.isEmpty()) 
        {
            return;
        }

        List<Bus__c> busesList = [
            SELECT Id, Passenger_Count__c, Bus_Status__c 
            FROM Bus__c 
            WHERE Id IN :scope
        ];

        List<Bus__c> busesToUpdateList = new List<Bus__c>();

        for (Bus__c bus : busesList) 
        {
            Decimal count = bus.Passenger_Count__c != null ? bus.Passenger_Count__c : 0;

            try 
            {
                if (count > 20) 
                {
                    throw new PassengersException('Bus ' + bus.Id + ' has more than 20 passengers.');
                }

                if (count == 20) 
                {
                    bus.Bus_Status__c = 'Full';
                } 
                else if (count > 10) 
                {
                    bus.Bus_Status__c = 'Limited Seats';
                } 
                else 
                {
                    bus.Bus_Status__c = 'Available';
                }

                busesToUpdateList.add(bus);
            } 
            catch (Exception e)
            {
                System.debug('Exception for Bus ' + bus.Id + ': ' + e.getMessage());
            }
        }

        if (!busesToUpdateList.isEmpty()) 
        {
            Database.update(busesToUpdateList, false);
        }
    }

    public void finish(Database.BatchableContext bc) 
    {
        System.debug('Batch process finished.');
    }
}
