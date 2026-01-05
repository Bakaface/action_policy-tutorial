---
type: lesson
title: Welcome to Action Policy
editor: false
terminal: false
---

# Welcome to Action Policy

Authorization is one of the most critical parts of any web application. It answers the question: **"Is this user allowed to perform this action?"**

Action Policy is a powerful authorization framework for Ruby and Rails applications. Created by [Vladimir Dementyev](https://github.com/palkan) (Evil Martians), it provides a modern, flexible, and feature-rich approach to handling authorization.

## What You'll Learn

In this tutorial, you'll build authorization for a Rails e-commerce application called "Store". You'll learn how to:

- Install and configure Action Policy
- Write policy classes with authorization rules
- Authorize controller actions using `authorize!`
- Check permissions in views with `allowed_to?`
- Use advanced features like aliases, pre-checks, and scoping
- Track failure reasons for better error messages
- Test your policies thoroughly

## Prerequisites

This tutorial assumes you have basic knowledge of:

- Ruby programming language
- Ruby on Rails framework
- MVC architecture (Models, Views, Controllers)

## The Store Application

Throughout this tutorial, we'll work with a simple e-commerce application that has:

- **Products** - Items that can be viewed, created, edited, and deleted
- **Users** - People who interact with the application (admins and regular users)

Our goal is to implement authorization rules like:

- Anyone can view products
- Only authenticated users can create products
- Users can only edit their own products
- Only admins can delete products

Let's get started!
