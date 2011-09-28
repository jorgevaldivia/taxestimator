class TaxController < ApplicationController

  def index
  end

  def result

    @taxes = Array.new();

    @income = 0;
    @deductibles = 0;
    @standardDeduction = 5700;
    @exemption = 3650;
    @brackets = Hash.new
    @brackets = {83600 => 0.28, 34500 => 0.25, 8500 => 0.15, 0 => 0.10}
    @taxable = 0;
    @defaultDeductions = 0;

    if(params[:joint])
      @brackets = {139350 => 0.28, 69000 => 0.25, 17000 => 0.15, 0 => 0.10}
      @standardDeduction = @standardDeduction *2;
    end

    if(params[:income])
      @income = params[:income].to_f
      
      w2tax = calculateW2Tax();
      deds = 0;
      while(deds <= 25000)
        tentax = calculate1099Tax(deds);
        
        anon = Hash.new;
        anon["w2tax"] = w2tax.round(2);
        anon["1099tax"] = tentax.round(2);
        anon["deductibles"] = deds.round(2);
        @taxes.push(anon);
        
        deds = deds + 1000;
      end
    end
  end

  def calculateW2Tax
    #global income, standardDeduction, exemption, brackets, taxable, defaultDeductions;
    
    rate = 0.22;
    taxableIncome = @income - @standardDeduction - @exemption;
    @taxable = taxableIncome;
    
    @defaultDeductions = @standardDeduction + @exemption;
    tax = 0;
    
    loopIncome = taxableIncome;
    loopTax = 0;
    @brackets.each { |i, value|
      if(loopIncome >= i)
        bracketIncome = loopIncome - i;
        if(bracketIncome >= 0)
          loopTax += (bracketIncome * (value + 0.07));
        end
        loopIncome = loopIncome - bracketIncome;
      end
      puts "**********************************i is: #{loopIncome} - #{i} - #{bracketIncome}\n"
    }
    
    tax = loopTax;
    return tax
  end

  def calculate1099Tax(deductibles)
    #global income, standardDeduction, exemption, brackets;
    
    businessRate = 0.153;
    grossRate = 0.9325;
    rate = 0.15;
    
    businessIncome = (@income - deductibles) * grossRate;
    seTax = businessIncome * businessRate;
    
    taxableIncome = businessIncome - @standardDeduction - @exemption - (seTax / 2);
    
    loopIncome = taxableIncome;
    loopTax = 0;
    @brackets.each { |i, value|
      if(loopIncome >= i)
        bracketIncome = loopIncome - i;
        if(bracketIncome >= 0)
          loopTax += (bracketIncome * (value + 0.00));
        end
        loopIncome = loopIncome - bracketIncome;
      end
    }
    
    tax = loopTax;
    
    
    totalTax = seTax + tax;
    
    return totalTax;
  end
end
