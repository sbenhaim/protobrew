The Humon Wiki
==============

Getting Started
---------------

To get started, you will need to be running either a posix operating
system (linux, osx, bsd).  Instructions are provided here for setting
up a development environment under Ubuntu (13.10).

The basic things one needs to develop are:
 - nodejs (v0.10)
 - npm (node package manager)
 - meteorite

To install these, the following process can be followed (google to
determine analogous steps for other environments):

Step 1: Install nodejs (recent)/npm from chris-lea ppa:

    $ sudo apt-get update
    $ sudo apt-get install -y python-software-properties python g++ make curl
    $ sudo add-apt-repository -y ppa:chris-lea/node.js
    $ sudo apt-get update
    $ sudo apt-get install nodejs

Step 2: Install meteorite using npm

    $ sudo -H npm install -g meteorite

Step 3: Install meteor from meteor install site

    $ curl https://install.meteor.com | /bin/sh

Step 4: Install meteorite dependencies

    $ cd path/to/wiki/source
    $ mrt install

Step 5: Run the wiki!

    $ meteor

Application Deployment
----------------------

Currently, the wiki is deployed to a server on rackspace.  Deployment
and configuration management is done using fabric.

Install Fabric (can also be installed via pip)

    $ sudo apt-get install fabric

Fabric defines different commands that can be executed in "fabfile.py"
in the root of the project.  It is encouraged that ssh keys be setup
with the machines to which things are being deployed to make things
easier on ones self.

Here's an example of how one would deploy to the staging server

    $ fab staging deploy

Data Model
----------

The data model that exists today has the following basic model collections
that are defined by the wiki application:

    Wikis:
     {
      name: "company_name",
      visibility: "public"
      owners: [uid1, uid2, uid3],
      readers: [uid1, uid2, uid3],
      writers: [uid1, uid2, uid3],
      admins: [uid1, uid2, uid3]
     }

    Entries:
      {
        _id: "gjQH4bGKLokvjJ2Gn",
        title: "home".
        context: null,
        mode: "public",
        tags: ["tag1", "tag2"],
        text: "Blah, Blah, Blah"
      }

    Tags:
      {
        _id: "pDo4KTfYusHoZNNci",
        name: "tag1"
      }

    Revisions:
      {
        _id: "csYmjCQLFqoFknE6z",
        entryId: "gjQH4bGKLokvjJ2Gn",
        date: <date>,
        text: "The entry at this revision",
        author: "xgSCswxkEyXMHt8uW"
      }

In addition to these, additional collections are defined by some 3rd
party packages.

Meteor Accounts (http://docs.meteor.com/#accounts_api):

    Meteor.users:
      {
        _id: "bbca5d6a-2156-41c4-89da-0329e8c99a4f",  // Meteor.userId()
        username: "cool_kid_13", // unique name
        emails: [
          // each email address can only belong to one user.
          { address: "cool@example.com", verified: true },
          { address: "another@different.com", verified: false }
        ],
        createdAt: Wed Aug 21 2013 15:16:52 GMT-0700 (PDT),
        profile: {
          // The profile is writable by the user by default.
          name: "Joe Schmoe"
        },
        services: {
          facebook: {
            id: "709050", // facebook id
            accessToken: "AAACCgdX7G2...AbV9AZDZD"
          },
          resume: {
            loginTokens: [
              { token: "97e8c205-c7e4-47c9-9bea-8e2ccc0694cd",
                when: 1349761684048 }
            ]
          }
        }
      }
