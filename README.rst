.. role:: ruby(code)
    :language: ruby

.. role:: sh(code)
    :language: sh

money-ecb
==========

.. image:: https://travis-ci.org/ct-clearhaus/money-ecb.png?branch=master
    :alt: Build Status
    :target: https://travis-ci.org/ct-clearhaus/money-ecb

.. image:: https://codeclimate.com/github/ct-clearhaus/money-ecb.png
    :alt: Code Climate
    :target: https://codeclimate.com/github/ct-clearhaus/money-ecb

.. image:: https://gemnasium.com/ct-clearhaus/money-ecb.png
    :alt: Dependency Status
    :target: https://gemnasium.com/ct-clearhaus/money-ecb


Introduction
------------

This gem is a RubyMoney_ bank that can exchange ``Money`` using rates from the
ECB (European Central Bank). It will automatically keep the rates updated.

.. _RubyMoney: http://rubymoney.github.io/money

Installation
------------

.. code-block:: sh

    gem install money-ecb

In your ``Gemfile`` may want to have :ruby:`gem 'money-ecb', :require =>
'money/bank/ecb'`.

Dependencies
............

- RubyMoney's ``money`` gem
- ``rubyzip`` gem


Example
-------

Using ``money`` and ``monetize``:

.. code-block:: ruby

    require 'money'
    require 'money/bank/ecb'
    require 'monetize/core_extensions'

    Money.default_bank = Money::Bank::ECB.new

    puts '1 EUR'.to_money.exchange_to(:USD)


Rounding
--------

By default, ``Money::Bank``'s will truncate. If you prefer to round:

.. code-block:: ruby

    puts '1 EUR'.to_money.exchange_to(:USD) {|x| x.round}

If you would like to have rounding done by default, you can set the default when
creating the ``ECB`` instance:

.. code-block:: ruby

    Money.default_bank = Money::Bank::ECB.new {|x| x.round}

Local cache file
----------------

For your convenience, :ruby:`.new` will accept a string representing a file
path.

If the file path holds a valid CSV file with exchange rates, the rates will be
used for conversion (unless newer rates are available; if so, new rates will be
fetched—see `auto-update`_). If the file does not exist or is "somehow bogus",
new rates will be downloaded from the European Central Bank and stored in the
file (or an :ruby:`InvalidCacheError` will be raise if `auto-update`_ is off).


.. _`auto-update`:

Auto-update rates
-----------------

The European Central Bank publishes foreign exchange rates daily, and they
should be available at 14:00 CE(S)T. The cache is automatically updated when
doing an exchange after new rates has been published; to disable this, set
:ruby:`#auto_update = false`; to force, :ruby:`#update_cache` and
:ruby:`#reload` (or both in one take, :ruby:`#update`).

Also notice that when instantiating an :ruby:`ECB`, rates will be loaded from
the cache file, and if that fails, new rates will be fetched automatically. So
if you want to handle updating rates "by hand", you should place a valid cache
before :ruby:`.new` and then call :ruby:`#reload` after you updated the cache.

.. _`Can I code my own cache?`:

Can I code my own cache?
------------------------

Yes, just :ruby:`include Money::Bank::ECB::Cache` and implement
:ruby:`.new_from?` (if you accept what :ruby:`.new` was given) and
:ruby:`.priority` (let it be :math:`\geq` :ruby:`2` since :ruby:`0` and
:ruby:`1` are already used for :ruby:`SimpleCache` and :ruby:`CacheFile`
respectively). No monkey patching needed!


Contribute
----------

* `Fork <https://github.com/ct-clearhaus/money-ecb/fork>`_
* Clone
* :sh:`bundle install && bundle exec rake test`
* Make your changes
* :sh:`bundle exec rake test` again, preferably against Ruby 1.9.3, 2.0.0 and
  2.1.0 (`Travis <https://travis-ci.org/ct-clearhaus/money-ecb/pull_requests>`_
  will do that).
* Create a Pull Request
* Enjoy!
