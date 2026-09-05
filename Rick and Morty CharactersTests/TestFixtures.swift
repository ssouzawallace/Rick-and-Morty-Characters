//
//  TestFixtures.swift
//  Rick and Morty CharactersTests
//
//  Created by Copilot
//

import Foundation

var singleCharacterJson: String {
    """
    {
       "id":1,
       "name":"Rick Sanchez",
       "status":"Alive",
       "species":"Human",
       "type":"",
       "gender":"Male",
       "origin":{
          "name":"Earth (C-137)",
          "url":"https://rickandmortyapi.com/api/location/1"
       },
       "location":{
          "name":"Citadel of Ricks",
          "url":"https://rickandmortyapi.com/api/location/3"
       },
       "image":"https://rickandmortyapi.com/api/character/avatar/1.jpeg",
       "episode":[
          "https://rickandmortyapi.com/api/episode/1"
       ],
       "url":"https://rickandmortyapi.com/api/character/1",
       "created":"2017-11-04T18:48:46.250Z"
    }
    """
}

var characterWithEmptyFieldsJson: String {
    """
    {
       "id":99,
       "name":"Test Character",
       "status":"Unknown",
       "species":"",
       "type":"",
       "gender":"Genderless",
       "origin":{
          "name":"",
          "url":""
       },
       "location":{
          "name":"",
          "url":""
       },
       "image":"https://example.com/avatar.jpeg",
       "episode":[],
       "url":"https://example.com/character/99",
       "created":"2020-01-01T00:00:00.000Z"
    }
    """
}

var characterWithUnknownEnumsJson: String {
    """
    {
       "id":100,
       "name":"Alien Bob",
       "status":"Zombified",
       "species":"Alien",
       "type":"Parasite",
       "gender":"Neuter",
       "origin":{
          "name":"Planet X",
          "url":"https://example.com/location/50"
       },
       "location":{
          "name":"Dimension C-500",
          "url":"https://example.com/location/51"
       },
       "image":"https://example.com/avatar.jpeg",
       "episode":["https://example.com/episode/1"],
       "url":"https://example.com/character/100",
       "created":"invalid-date"
    }
    """
}

var characterDeadFemaleJson: String {
    """
    {
       "id":50,
       "name":"Dead Character",
       "status":"Dead",
       "species":"Robot",
       "type":"Mechanical",
       "gender":"Female",
       "origin":{
          "name":"Factory",
          "url":"https://example.com/location/10"
       },
       "location":{
          "name":"Junkyard",
          "url":"https://example.com/location/11"
       },
       "image":"https://example.com/avatar.jpeg",
       "episode":["https://example.com/episode/5"],
       "url":"https://example.com/character/50",
       "created":"2019-06-15T12:30:00.000Z"
    }
    """
}

var listResponseWithNoNextPageJson: String {
    """
    {
       "info":{
          "count":1,
          "pages":1,
          "next":null,
          "prev":null
       },
       "results":[
          {
             "id":1,
             "name":"Rick Sanchez",
             "status":"Alive",
             "species":"Human",
             "type":"",
             "gender":"Male",
             "origin":{
                "name":"Earth (C-137)",
                "url":"https://rickandmortyapi.com/api/location/1"
             },
             "location":{
                "name":"Citadel of Ricks",
                "url":"https://rickandmortyapi.com/api/location/3"
             },
             "image":"https://rickandmortyapi.com/api/character/avatar/1.jpeg",
             "episode":[
                "https://rickandmortyapi.com/api/episode/1"
             ],
             "url":"https://rickandmortyapi.com/api/character/1",
             "created":"2017-11-04T18:48:46.250Z"
          }
       ]
    }
    """
}
