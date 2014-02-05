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

This gem is a RubyMoney bank that can exchange ``Money`` using rates from the
ECB (European Central Bank).


Installation
------------

.. code-block:: sh

    gem install money-ecb

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

    Money.default_bank = Money::Bank::ECB.new('/tmp/ecb-fxr.cache')

    puts '1 EUR'.to_money.exchange_to(:USD)

If ``/tmp/ecb-fxr.cache`` is a valid CSV file with exchange rates, the rates
will be used for conversion (unless newer rates are available; if so, new rates
will be fetched—see `auto-update`_). If the file does not exist, new rates will be
downloaded from the European Central Bank and stored in the file. To update the
cache,

.. code-block:: ruby

    Money.default_bank.update


Rounding
--------

By default, ``Money::Bank``'s will truncate. If you prefer to round, exchange
methods will accept a block that will be yielded; that block is intended for
rounding when exchanging (continuing from above):

.. code-block:: ruby

    puts '1 EUR'.to_money.exchange_to(:USD) {|x| x.round}


.. _`auto-update`:

Auto-update rates
-----------------

The European Central Bank publishes daily foreign exchange rates every day, and
they should be available at 14:00 CET. The cache is automatically updated when
doing an exchange after new rates has been published; to disable this, set
``Money::Bank::ECB#auto_update = false``.


Contribute
----------

* `Fork <https://github.com/ct-clearhaus/money-ecb/fork>`_
* Clone
* ``bundle install``
* ``bundle exec rake test``
* Make your changes
* Test your changes
* Create a Pull Request and check `Travis
  <https://travis-ci.org/ct-clearhaus/money-ecb/pull_requests>`_
* Enjoy!
