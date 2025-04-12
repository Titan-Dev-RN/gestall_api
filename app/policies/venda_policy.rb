class VendaPolicy
    attr_reader :user, :venda
  
    def initialize(user, venda)
      @user = user
      @venda = venda
    end
  
    def create?
      user.funcionario?
    end
  
    def finalizar?
      user.funcionario? && venda.pendente? && venda.usuario == user
    end
  end