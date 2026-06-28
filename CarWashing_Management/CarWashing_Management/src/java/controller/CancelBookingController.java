package controller;

import dao.BookingDAO;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet(name = "CancelBookingController",
        urlPatterns = {"/CancelBookingController"})
public class CancelBookingController extends HttpServlet {

    protected void processRequest(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        try {

            int bookingId
                    = Integer.parseInt(
                            request.getParameter("bookingId"));

            BookingDAO dao = new BookingDAO();

            if (dao.canCancelBooking(bookingId)) {

                dao.cancelBooking(bookingId);

            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        response.sendRedirect(
                "UpcomingBookingController");
    }

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        processRequest(request, response);
    }

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        processRequest(request, response);
    }
}
