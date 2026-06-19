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
    private String time;
    private boolean isFull;
    private boolean isPriority;
    private int bookedCount;

    public TimeSlot() {
    }

    public TimeSlot(int slotNumber, String time, boolean isFull, boolean isPriority, int bookedCount) {
        this.slotNumber = slotNumber;
        this.time = time;
        this.isFull = isFull;
        this.isPriority = isPriority;
        this.bookedCount = bookedCount;
    }

    

    public String getTime() {
        return time;
    }

    public void setTime(String time) {
        this.time = time;
    }

    public boolean isIsFull() {
        return isFull;
    }

    public void setIsFull(boolean isFull) {
        this.isFull = isFull;
    }

    public int getBookedCount() {
        return bookedCount;
    }

    public void setBookedCount(int bookedCount) {
        this.bookedCount = bookedCount;
    }

    public int getSlotNumber() {
        return slotNumber;
    }

    public void setSlotNumber(int slotNumber) {
        this.slotNumber = slotNumber;
    }

    public boolean isIsPriority() {
        return isPriority;
    }

    public void setIsPriority(boolean isPriority) {
        this.isPriority = isPriority;
    }
    
    
}
