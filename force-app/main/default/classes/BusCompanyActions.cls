public with sharing class BusCompanyActions 
{
    @AuraEnabled(cacheable=true)
    public static List<Bus__c> getBusesWithPassengers(Id busCompanyId) 
    {
        if (busCompanyId == null) 
        {
            return new List<Bus__c>();
        }
        List<Bus__c> busesList = new List<Bus__c>();

        busesList = [
            SELECT Id, Name, Bus_Status__c, Passenger_Count__c,
                   (SELECT Id, Name FROM Passengers__r ORDER BY Name)
            FROM Bus__c
            WHERE Bus_Company__c = :busCompanyId
            ORDER BY Name
        ];

        return busesList;
    }
}