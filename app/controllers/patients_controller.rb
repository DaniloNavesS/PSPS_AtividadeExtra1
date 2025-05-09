require 'grpc'
require_relative '../services/grpc/patient_service_services_pb'

class PatientsController < ApplicationController
  GRPC_ENABLED = ENV['GRPC_ENABLED'] == 'true'

  def index
    if GRPC_ENABLED
      begin
        # Usa o Server A para listar pacientes
        stub = Patient::PatientService::Stub.new('localhost:50051', :this_channel_is_insecure)
        response = stub.list_patients(Patient::ListPatientsRequest.new)
        @patients = response.patients
      rescue GRPC::BadStatus => e
        flash.now[:alert] = "Erro ao conectar com o servidor gRPC: #{e.message}"
        @patients = []
      end
    else
      # Modo de desenvolvimento: usa o banco local
      @patients = Patient.all
    end
  end

  def show
    if GRPC_ENABLED
      begin
        # Usa o Server A para buscar um paciente específico
        stub = Patient::PatientService::Stub.new('localhost:50051', :this_channel_is_insecure)
        response = stub.get_patient(Patient::GetPatientRequest.new(id: params[:id]))
        @patient = response.patient
      rescue GRPC::BadStatus => e
        flash.now[:alert] = "Erro ao conectar com o servidor gRPC: #{e.message}"
        redirect_to patients_path
      end
    else
      # Modo de desenvolvimento: usa o banco local
      @patient = Patient.find(params[:id])
    end
  end

  def new
    @patient = Patient.new
  end

  def create
    if GRPC_ENABLED
      begin
        # Usa o Server B para criar um novo paciente
        stub = Patient::PatientService::Stub.new('localhost:50052', :this_channel_is_insecure)
        
        response = stub.create_patient(
          Patient::CreatePatientRequest.new(
            name: patient_params[:name],
            birth_date: patient_params[:birth_date],
            cpf: patient_params[:cpf],
            sexo: patient_params[:sexo],
            numero: patient_params[:numero]
          )
        )
        
        redirect_to patients_path, notice: 'Paciente cadastrado com sucesso.'
      rescue GRPC::BadStatus => e
        @patient = Patient.new(patient_params)
        flash.now[:alert] = "Erro ao cadastrar paciente: #{e.message}"
        render :new, status: :unprocessable_entity
      end
    else
      # Modo de desenvolvimento: usa o banco local
      @patient = Patient.new(patient_params)
      if @patient.save
        redirect_to @patient, notice: 'Paciente cadastrado com sucesso.'
      else
        render :new, status: :unprocessable_entity
      end
    end
  end

  def edit
    if GRPC_ENABLED
      begin
        # Usa o Server A para buscar o paciente para edição
        stub = Patient::PatientService::Stub.new('localhost:50051', :this_channel_is_insecure)
        response = stub.get_patient(Patient::GetPatientRequest.new(id: params[:id]))
        @patient = response.patient
      rescue GRPC::BadStatus => e
        flash.now[:alert] = "Erro ao conectar com o servidor gRPC: #{e.message}"
        redirect_to patients_path
      end
    else
      # Modo de desenvolvimento: usa o banco local
      @patient = Patient.find(params[:id])
    end
  end

  def update
    if GRPC_ENABLED
      begin
        # Usa o Server B para atualizar o paciente
        stub = Patient::PatientService::Stub.new('localhost:50052', :this_channel_is_insecure)
        
        response = stub.update_patient(
          Patient::UpdatePatientRequest.new(
            id: params[:id],
            name: patient_params[:name],
            birth_date: patient_params[:birth_date],
            cpf: patient_params[:cpf],
            sexo: patient_params[:sexo],
            numero: patient_params[:numero]
          )
        )
        
        redirect_to patients_path, notice: 'Paciente atualizado com sucesso.'
      rescue GRPC::BadStatus => e
        @patient = Patient.new(patient_params)
        flash.now[:alert] = "Erro ao atualizar paciente: #{e.message}"
        render :edit, status: :unprocessable_entity
      end
    else
      # Modo de desenvolvimento: usa o banco local
      @patient = Patient.find(params[:id])
      if @patient.update(patient_params)
        redirect_to @patient, notice: 'Paciente atualizado com sucesso.'
      else
        render :edit, status: :unprocessable_entity
      end
    end
  end

  private

  def patient_params
    params.require(:patient).permit(:name, :birth_date, :cpf, :sexo, :numero)
  end

  #Controller para o GRPC
  def create
    # Cria stub para o gRPC Server A (supondo que roda na porta 50051)
    stub = Patient::PatientService::Stub.new('localhost:50051', :this_channel_is_insecure)

    # Faz a requisição gRPC
    response = stub.add_patient(
      Patient::PatientRequest.new(name: params[:name], birth_date: params[:birth_date])
    )

    render json: { grpc_response: response.message }
  end
end
