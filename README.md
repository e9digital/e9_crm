*NOTE his plugin requires the private e9_base CMS gem and WILL NOT WORK without it.*

CRM Plugin for the e9 CMS
=========================

To use, add as a gem and install by running:

    rails g e9_crm:install

Then modify the installed initializer as per your app, including
the controller module in your desired controllers, with the final
result looking something like this:

    require 'e9_crm'

    User.send :include, E9Crm::Backend::ActiveRecord

    Rails.configuration.after_initialize do
      [
        MyFirstTrackedController,
        MySecondTrackedController
      ].each {|c| c.send(:include, E9Crm::TrackingController) }
    end

NOTE: A few assumptions are made:
---------------------------------

1.    Your app has a "User" model
2.    Your app has a controller method #current_user to return the
      currently logged in user.
