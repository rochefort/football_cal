#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require 'mechanize'
require 'icalendar'
require_relative 'card'

class Football
  def initialize
    @agent = Mechanize.new
  end

  def update_all
    YAML.load_file('players.yaml').each do |name, settings|
      schedule(name, settings['url'], settings['title'])
    end
  end

  private

  def schedule(name, url, title)
    cards = scrape(url)
    create_ical(name, title, cards)
  end

  def create_ical(name, title, cards)
    cal = Icalendar::Calendar.new
    cal.timezone do |t|
      t.tzid = 'Asia/Tokyo'
      t.standard do |s|
        s.tzoffsetfrom = '+0900'
        s.tzoffsetto   = '+0900'
        s.tzname       = 'JST'
        s.dtstart      = '19700101T000000'
      end
    end
    cal.append_custom_property('X-WR-CALNAME;VALUE=TEXT', title)
    cards.each do |card|
      cal.event do |e|
        e.summary     = "#{card.section}節 #{card.rival}戦"
        e.description = "[#{card.home_away}]#{title} #{card.section}節 #{card.rival}戦"
        e.dtstart     = Icalendar::Values::DateTime.new(card.kickoff_at)
        e.dtend       = Icalendar::Values::DateTime.new(card.kickoff_at + 2.hour)
      end
    end
    cal.publish
    open("#{name}.ics", 'w') { |f| f.puts(cal.to_ical) }
  end

  # 0: 説         e.g.: 01
  # 1: 年月日（曜） e.g.: 2014/08/24（日）
  # 2: 開始       e.g.: 01:30
  # 3: スコア
  # 4: H/A
  # 5: 対戦相手
  def scrape(url)
    cards = []
    result = @agent.get(url)
    result.search('#scmsMainContentsSection > table > tbody > tr').each do |tr|
      tds = tr.search('td')
      section = tds[0].text.to_i
      date = tds[1].text.match(%r|\d{4}/\d{2}/\d{2}|)[0]
      time = tds[2].text
      time = nil if time == '--：--'
      home_away = tds[4].text
      rival = tds[5].text
      cards << Card.new(section, date, time, home_away, rival)
    end
    cards
  end
end

if $0 == __FILE__
  Football.new.update_all
end
