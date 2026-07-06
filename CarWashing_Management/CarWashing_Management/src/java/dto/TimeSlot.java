/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dto;

/**
 *
 * @author LENOVO
 */
public class TimeSlot {
    private int slotNumber;
    private String startTime;
    private String endTime;
    private int bookedCount; 
    private boolean isPast;
    private boolean isFull;
    private boolean isPriority;

    public TimeSlot() {
    }

    public TimeSlot(int slotNumber, String startTime, String endTime, int bookedCount, boolean isPast, boolean isFull, boolean isPriority) {
        this.slotNumber = slotNumber;
        this.startTime = startTime;
        this.endTime = endTime;
        this.bookedCount = bookedCount;
        this.isPast = isPast;
        this.isFull = isFull;
        this.isPriority = isPriority;
    }

    public int getSlotNumber() {
        return slotNumber;
    }

    public void setSlotNumber(int slotNumber) {
        this.slotNumber = slotNumber;
    }

    public String getStartTime() {
        return startTime;
    }

    public void setStartTime(String startTime) {
        this.startTime = startTime;
    }

    public String getEndTime() {
        return endTime;
    }

    public void setEndTime(String endTime) {
        this.endTime = endTime;
    }

    public int getBookedCount() {
        return bookedCount;
    }

    public void setBookedCount(int bookedCount) {
        this.bookedCount = bookedCount;
    }

    public boolean isIsPast() {
        return isPast;
    }

    public void setIsPast(boolean isPast) {
        this.isPast = isPast;
    }

    public boolean isIsFull() {
        return isFull;
    }

    public void setIsFull(boolean isFull) {
        this.isFull = isFull;
    }

    public boolean isIsPriority() {
        return isPriority;
    }

    public void setIsPriority(boolean isPriority) {
        this.isPriority = isPriority;
    }

   
    
}