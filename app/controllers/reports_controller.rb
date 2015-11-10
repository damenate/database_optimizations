class ReportsController < ApplicationController
  helper_method :memory_in_mb

  def all_data
    @start_time = Time.now
    @assembly = Assembly.find_by_name(params[:name])
    #
    # sequences = Sequence.where(assembly_id: @assembly.id)
    # sequence_ids = sequence.map {|s| s.id}
    #
    # genes = Gene.where(sequence_id: sequence_ids)
    # gene_ids = genes,map {|g| g.id}
    #
    # @hits = Hit.where(subject_id: gene_ids, subject_type: "Gene").order(percent_similarity: :desc)

    @hits = Hit.where(subject_id: Gene.where(sequence: Sequence.where(assembly: @assembly))).order(
    percent_similarity: :desc)
    @memory_used = memory_in_mb
  end

  def search
    if params[:search]
       results = []
       params[:search].split(" ").each do |w|
         q = "%#{w}%"
         results += Hit.where("match_gene_name LIKE ?", q)
         results += Hit.where(subject: Gene.joins(sequence: :assembly).where("genes.dna LIKE ? OR sequences.dna LIKE ? OR assemblies.name LIKE ?", q, q, q))
       end
       @hits = results.uniq
     end
  end


  private def memory_in_mb
    `ps -o rss -p #{$$}`.strip.split.last.to_i / 1024
  end
end
