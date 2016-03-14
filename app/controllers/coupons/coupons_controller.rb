class Coupons::CouponsController < Coupons::ApplicationController
  before_action :set_coupon, only: [:edit, :show, :update, :destroy, :remove, :duplicate]

  def apply
    coupon_code = params[:coupon]
    amount = BigDecimal(params.fetch(:amount, '0.0'))
    options = Coupons
              .apply(params[:coupon], amount: amount)
              .slice(:amount, :discount, :total)
              .reduce({}) {|buffer, (key, value)| buffer.merge(key => Float(value)) }

    render json: options
  end

  def index
    paginator = Coupons.configuration.paginator
    @coupons = Coupons::Collection.new(paginator.call(Coupon.order(created_at: :desc), params[:page]))
  end

  def new
    @coupon = Coupon.new
  end

  def create
    @coupon = Coupon.new(coupon_params)

    respond_to do |format|
      if @coupon.save
        format.html { redirect_to coupons_path, notice: t('coupons.flash.coupons.create.notice') }
        format.json { render :show, status: :created }
      else
        format.html { render :new }
        format.json { render json: @coupon.errors, status: :unprocessable_entity }
      end
    end
  end

  def show
  end

  def edit
  end

  def duplicate
    attributes = @coupon.attributes.symbolize_keys.slice(:description, :valid_from, :valid_until, :redemption_limit, :amount, :type)
    @coupon = Coupon.new(attributes)

    respond_to do |format|
      format.html { render :new }
      format.json { render :show }
    end
  end

  def update
    respond_to do |format|
      if @coupon.update(coupon_params)
        format.html { redirect_to coupons_path, notice: t('coupons.flash.coupons.update.notice') }
        format.json { render :show, status: :ok }
      else
        format.html { render :edit }
        format.json { render json: @coupon.errors, status: :unprocessable_entity }
      end
    end
  end

  def remove
  end

  def destroy
    @coupon.destroy!

    respond_to do |format|
      format.html { redirect_to coupons_path, notice: t('coupons.flash.coupons.destroy.notice') }
      format.json { head :no_content }
    end
  end

  def batch
    if params[:remove_action]
      batch_removal
    else
      respond_to do |format|
        format.html { redirect_to coupons_path, alert: t('coupons.flash.coupons.batch.invalid_action') }
        format.json { render json: { error: t('coupons.flash.coupons.batch.invalid_action') }, status: :unprocessable_entity }
      end
    end
  end

  private

    def set_coupon
      @coupon = Coupon.find(params[:id])
    end

    def batch_removal
      Coupon.where(id: params[:coupon_ids]).destroy_all

      respond_to do |format|
        format.html { redirect_to coupons_path, notice: t('coupons.flash.coupons.batch.removal.notice') }
        format.json { head :no_content }
      end
    end

    def coupon_params
      params
        .require(:coupon)
        .permit(:code, :redemption_limit, :description, :valid_from, :valid_until, :amount, :type)
    end

end
