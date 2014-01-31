FIXME-NAME
==========

.. image:: https://travis-ci.org/ct-clearhaus/money-ecb.png?branch=master
    :target: https://travis-ci.org/ct-clearhaus/money-ecb

Introduction
------------

This gem is a ``RubyMoney::Bank`` that can exchange ``Money`` using rates from
the ECB (European Central Bank).

Installation
------------

.. code-block:: sh

    gem install FIXME-NAME

Dependencies
------------

- RubyMoney's ``money`` gem
- ``rubyzip`` gem

Example
-------

Using ``money`` and ``monetize``:

.. code-block:: ruby

    require 'money'
    require 'money/bank/ecb'
    require 'monetize'

    Money.default_bank = Money::Bank::ECB.new('/tmp/ecb-fxr.cache')

    puts "1 EUR".to_money.exchange_to(:USD)

If ``/tmp/ecb-fxr.cache`` is a valid CSV file with exchange rates, the rates
will be used for conversion. If the file does not exist, new rates will be
downloaded from the European Central Bank and stored in the file. To update the
cache,

.. code-block:: ruby

    Money::Bank::ECB.instance.update
