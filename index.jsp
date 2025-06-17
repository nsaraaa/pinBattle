<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String contextPath = request.getContextPath();
    response.sendRedirect(contextPath + "/login.jsp");
%> 