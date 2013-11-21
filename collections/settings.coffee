root = exports ? this
@Settings = new Meteor.Collection("settings")

Settings.allow
  insert: root.isAdminById
  update: root.isAdminById
  remove: root.isAdminById
