class ProdutoPolicy
    attr_reader :user, :produto
  
    def initialize(user, produto)
      @user = user
      @produto = produto
    end
  
    def create?
      user.admin_loja?
    end
  
    def update?
      user.admin_loja? || (user.funcionario? && user.informacao_loja == produto.informacao_loja)
    end
  
    def destroy?
      user.admin_loja?
    end
  end